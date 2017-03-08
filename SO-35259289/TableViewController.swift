//
//  TableViewController.swift
//  SO-35259289
//
//  Copyright © 2017 Xavier Schott
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

// UITextView Binding class
class TableViewTextViewCell : UITableViewCell, UITextViewDelegate {
    var refreshCell:(() -> Void)? = nil
    var textViewDirtyCount = 0
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        textViewDirtyCount += 1
        perform(#selector(TableViewTextViewCell.queuedTextVewDidChange), with: nil, afterDelay: 0.3) // Wait until typing stopped
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDirtyCount = 0 // initialize queuedTextVewDidChange
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDirtyCount = -1 // prevent any further queuedTextVewDidChange
    }
    
    func queuedTextVewDidChange() {
        if textViewDirtyCount > 0 {
            textViewDirtyCount -= 1
            if 0 == textViewDirtyCount, let refreshCell = refreshCell {
                refreshCell()
            }
        }
    }
}

class TableViewController: UITableViewController {
    let cellCount = 1 + (3 * 4) + 1 // header, 3 sets, footer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use Autolayout to handle size
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
            
        case cellCount-1:
            return tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath)
            
        default:
            let modulo = (indexPath.row - 1) % 4
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell\(modulo)", for: indexPath)
            if let textFieldCell = cell as? TableViewTextViewCell {
                textFieldCell.refreshCell = {
                    () -> Void in
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
            return cell
        }
    }
}
