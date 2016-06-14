import UIKit
import WebKit

extension WebViewController {

    /**
     Setup the refresh control for reloading the web view.
     */
    public func setupRefreshControl() {
        let newRefreshControl = UIRefreshControl()
        newRefreshControl.attributedTitle = NSAttributedString(string: "")
        newRefreshControl.addTarget(self, action: #selector(WebViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.insertSubview(newRefreshControl, atIndex: 0)
        refreshControl = newRefreshControl
    }
    
    /**
     This action is called by the refresh control.
     */
    public func refresh() {
        loadURL(rootURL)
    }

    /**
     This sets up progress view in the top of the view. If progressView is non-nil
     the we use that instead. If you want to create your own progress view you can override this
     method or you can set the outlet in interface builder.
     */
    public func setupProgressView() {
        if let _ = progressView {
            return
        }
        
        progressView = UIProgressView(progressViewStyle: .Default)
        guard let progressView = progressView else {
            return
        }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        let views = Dictionary(dictionaryLiteral: ("progressView", progressView))
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(hConstraints)

        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[progressView(1)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(vConstraints)
        
        let yConstraint = NSLayoutConstraint(item: progressView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0)
        view.addConstraint(yConstraint)
    }

    /**
     This sets up an activity indicator in the center of the screen. If activityIndicator is non-nil
     the we use that instead. If you want to create your own activityIndicator you can override this 
     method or you can set the outlet in interface builder.
     */
    public func setupActivityIndicator() {
        if let _ = activityIndicator {
            return
        }
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        guard let activityIndicator = activityIndicator else {
            return
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let xCenterConstraint = NSLayoutConstraint(item: activityIndicator,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)
        view.addConstraint(xCenterConstraint)
        
        let yConstraint = NSLayoutConstraint(item: activityIndicator,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: bottomLayoutGuide,
            attribute: .Top,
            multiplier: 1,
            constant: -20)
        view.addConstraint(yConstraint)
    }
    
    /**
     This is called when there is a posibly a need to update the status of the activity indicator. 
     For example, when the web view loading status has changed.
     
     - parameter webView: The web view whose activity we should indicate.
     */
    func updateActivityIndicatorWithWebView(webView: WKWebView) {
        guard let activityIndicator = activityIndicator else {
            return
        }
        
        if webView.loading {
            if let refreshControl = refreshControl where !refreshControl.refreshing {
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            }
        } else {
            activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    /**
     This is called when there is a posibly a need to update the status of the progress view.
     For example, when the web view's estimated progress has changed.
     
     - parameter webView: The web view whose progress we should indicate.
     */
    func updateProgressViewWithWebView(webView: WKWebView) {
        guard let progressView = progressView else {
            return
        }
        
        progressView.hidden = !webView.loading
        if !webView.loading {
            progressView.setProgress(0, animated: false)
        }
    }
}

extension WebViewController: WebViewObserverDelegate {
    
    /**
     Called when the webView updates the value of its title property.
     
     - parameter webView: The instance of WKWebView that updated its title property.
     - parameter title: The value that the WKWebView updated its title property to.
     */
    public func webView(webView: WKWebView, didChangeTitle title: String?) {
        navigationItem.title = title
    }

    /**
     Called when the webView updates the value of its loading property.
     - Parameter webView: The instance of WKWebView that updated its loading property.
     - Parameter loading: The value that the WKWebView updated its loading property to.
     */
    public func webView(webView: WKWebView, didChangeLoading loading: Bool) {
        updateActivityIndicatorWithWebView(webView)
        updateProgressViewWithWebView(webView)
        if !loading {
            if refreshControl?.refreshing ?? false {
                refreshControl?.endRefreshing()
            }
            if let _ = webView.URL {
                hasLoadedContent = true
            }
        }
    }
    
    /**
     This is called when the web view change its estimate loading progress.
     
     - parameter webView:           The web view.
     - parameter estimatedProgress: The estimated fraction of the progress toward loading the page.
     */
    public func webView(webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double) {
        progressView?.setProgress(Float(estimatedProgress), animated: true)
    }
    
}
