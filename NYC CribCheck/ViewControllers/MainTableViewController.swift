
//  MainTableViewController.swift
import FoldingCell
import UIKit
import SnapKit

// FOR TYLER'S USE ONLY 

class MainTableViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // All comments
            selectedSegment = 0
        case 1: // All posts
            selectedSegment = 1
        case 2: // About
            selectedSegment = 2
        default:
            break
        }
    }
    
    private let headerStopOffset:CGFloat = 200 - 64
    private let hiddenLabelDistanceToTop:CGFloat = 30.0
    //    private var contentToDisplay: contentTypes = .allPosts // might need this later
    private var selectedSegment = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var headerBlurImageView: UIImageView = {
        let biv = UIImageView()
        biv.alpha = 0.0
        biv.contentMode = .scaleAspectFill
        //        biv.image = #imageLiteral(resourceName: "image").blur(radius: 10, tintColor: UIColor.clear, saturationDeltaFactor: 1)
        return biv
    }()
    
    private lazy var headerImageView: UIImageView = {
        let hiv = UIImageView()
        hiv.image = #imageLiteral(resourceName: "image")
        hiv.contentMode = .scaleAspectFill
        return hiv
    }()
    
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
    }

    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
    
    private func setupUI() {
        
//        // Header - Profile image
//        profileImage.layer.borderWidth = 4
//        profileImage.layer.borderColor = .white
//        profileImage.layer.cornerRadius = 20
//        profileImage.clipsToBounds = true
        
        // Header - Edit profile button
//        editProfileButton.layer.borderColor = UIColor.gray.cgColor
//        editProfileButton.layer.borderWidth = 1
//        editProfileButton.layer.cornerRadius = 14
        
        headerView.clipsToBounds = true
        
        // Header - imageView
        headerView.insertSubview(headerImageView, belowSubview: headerLabel)
        headerImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.snp.leading)
            make.top.equalTo(headerView.snp.top)
            make.height.equalTo(headerView.snp.height)
            make.trailing.equalTo(view.snp.trailing)
        }
        // Header - blurImageView
        headerView.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        headerBlurImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.view.snp.leading)
            make.top.equalTo(headerView.snp.top)
            make.height.equalTo(headerView.snp.height)
            make.trailing.equalTo(self.view.snp.trailing)
        }
    }
}

// MARK: - TableView

extension MainTableViewController: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 5
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

        cell.number = indexPath.row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}

extension MainTableViewController: UITableViewDelegate {
    
}

extension MainTableViewController: UIScrollViewDelegate {
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y + headerView.bounds.height
        var profileImageTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN - Sticky Header
        if offset < 0 {
            let headerScaleFactor: CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            // Hide views if scrolled super fast
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
        }
            // SCROLLING
        else {
            // HEADER CONTAINER
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-headerStopOffset, -offset), 0)
            
            // HIDDEN LABEL
            headerLabel.isHidden = false
            let alignToNameLabel = -offset + handleLabel.frame.origin.y + headerView.frame.height + headerStopOffset
            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, hiddenLabelDistanceToTop + headerStopOffset))
            
            // BLUR
            headerBlurImageView.alpha = min(1.0, (offset - alignToNameLabel)/hiddenLabelDistanceToTop)
            
            // PROFILE IMAGE
            // Slow down the animation
            let profileImageScaleFactor = (min(headerStopOffset, offset)) / profileImage.bounds.height / 3.4
            let profileImageSizeVariation = ((profileImage.bounds.height * (1.0 + profileImageScaleFactor)) - profileImage.bounds.height) / 2
            
            profileImageTransform = CATransform3DTranslate(profileImageTransform, 0, profileImageSizeVariation, 0)
            profileImageTransform = CATransform3DScale(profileImageTransform, 1.0 - profileImageScaleFactor, 1.0 - profileImageScaleFactor, 0)
            
            if offset <= headerStopOffset {
                if profileImage.layer.zPosition < headerView.layer.zPosition {
                    headerView.layer.zPosition = 0
                }
                
            } else {
                if profileImage.layer.zPosition >= headerView.layer.zPosition {
                    headerView.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        headerView.layer.transform = headerTransform
        profileImage.layer.transform = profileImageTransform
        
        // MARK: - Segmented control offset *Maybe put as section header?, not sure if it works with multiple sections*
        // Segment control
        let segmentViewOffset = profileView.bounds.height - segmentedView.bounds.height - offset
        var segmentTransform = CATransform3DIdentity
        
        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -headerStopOffset), 0)
        segmentedView.layer.transform = segmentTransform
        
        // Set scroll view insets just underneath the segment control
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.bounds.maxY, 0, 0, 0)
}
}