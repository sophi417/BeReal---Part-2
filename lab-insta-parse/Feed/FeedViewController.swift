//
//  FeedViewController.swift
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // spinner that shows when you pull down on the feed
    private let refreshControl = UIRefreshControl()

    // how many posts to load at a time
    private let pageSize = 10

    // so we don't load the same page twice at once
    private var isLoading = false

    // false once the server runs out of posts
    private var hasMorePosts = true

    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        // hook up pull to refresh
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // start over from the newest posts
        queryPosts(reset: true)
    }

    // runs when the user pulls down on the feed
    @objc private func onPullToRefresh() {
        queryPosts(reset: true)
    }

    // reset = true -> load the first 10 again
    // reset = false -> load the next 10 and add them to the end
    private func queryPosts(reset: Bool) {

        // don't start another load if one is already running
        if isLoading { return }
        isLoading = true

        // how many posts to skip (the ones we already have)
        let skipCount = reset ? 0 : posts.count

        // only get posts from the last 24 hours
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let query = Post.query()
            .include("user")
            .where("createdAt" >= yesterday)
            .order([.descending("createdAt")])
            .limit(pageSize)
            .skip(skipCount)

        // run the query
        query.find { [weak self] result in
            guard let self = self else { return }

            self.isLoading = false
            // stop the spinner once the server answers
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let newPosts):
                if reset {
                    self.posts = newPosts
                } else {
                    self.posts.append(contentsOf: newPosts)
                }
                // if we got less than 10 back, there's nothing left to load
                self.hasMorePosts = newPosts.count == self.pageSize
            case .failure(let error):
                self.showAlert(description: error.localizedDescription)
            }
        }
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt
                   
                   indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    // runs right before each row shows on screen
   
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        // when the last post is about to show, load the next 10
if indexPath.row == posts.count - 1 && hasMorePosts {
            queryPosts(reset: false)
        }
    }
}
