//
//  TreeViewController.swift
//  TreeTable
//
//  Created by Nagender Kumar on 12/04/24.
//

import UIKit
import Foundation

class TreeViewController: UITableViewController {
    var rootNodes: [TreeNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseJSONData()
    }
    
    func parseJSONData() {
        guard let path = Bundle.main.path(forResource: "TreeJson", ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let templates = json["templates"] as? [String: Any],
              let items = templates["items"] as? [[String: Any]] else {
            return
        }
        
        rootNodes = items.map { parseNode($0) }
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootNodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreeViewCell", for: indexPath) as! TreeViewCell
        let node = rootNodes[indexPath.row]
        
        cell.nameLabel?.text = node.name
        cell.indentationLevel = node.depth // Set the indentation level
        cell.indentationWidth = 20 // Set the base indentation width
        
        if node.items.isEmpty {
            cell.disclosureButton?.isHidden = true
        } else {
            cell.disclosureButton?.isHidden = false
            let imageName = node.isExpanded ? "minus" : "plus"
            cell.disclosureButton?.setImage(UIImage(named: imageName), for: .normal)
        }
        
        cell.disclosureButtonTapAction = {
            self.toggleNode(at: indexPath)
        }
        
        // Adjust cell content indentation
        cell.contentView.frame.origin.x = CGFloat(node.depth) * cell.indentationWidth
        
        return cell
    }









    func parseNode(_ json: [String: Any], parent: TreeNode? = nil, depth: Int = 0) -> TreeNode {
        guard let name = json["name"] as? String,
              let items = json["items"] as? [[String: Any]] else {
            return TreeNode(name: "", isExpanded: false, items: [], parent: parent, depth: depth)
        }

        let children = items.map { parseNode($0, parent: TreeNode(name: name, isExpanded: false, items: [], parent: parent, depth: depth + 1), depth: depth + 1) }
        return TreeNode(name: name, isExpanded: false, items: children, parent: parent, depth: depth)
    }


    func toggleNode(at indexPath: IndexPath) {
        let node = rootNodes[indexPath.row]
        node.isExpanded.toggle()

        tableView.beginUpdates()
        if node.isExpanded {
            // Update your data source to include the children of the expanded node
            rootNodes.insert(contentsOf: node.items, at: indexPath.row + 1)

            // Set the parent for the inserted nodes
            node.items.forEach { $0.parent = node }

            // Create an array of index paths for the inserted rows
            var indexPaths = [IndexPath]()
            for i in 0..<node.items.count {
                indexPaths.append(IndexPath(row: indexPath.row + 1 + i, section: indexPath.section))
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        } else {
            // Update your data source to remove the children of the collapsed node
            var removedIndexPaths = [IndexPath]()
            var removedNodes = [TreeNode]()
            for (index, item) in rootNodes.enumerated() {
                if let parent = item.parent, parent == node {
                    removedIndexPaths.append(IndexPath(row: index, section: indexPath.section))
                    removedNodes.append(item)
                }
            }
            rootNodes.removeAll(where: { removedNodes.contains($0) })

            tableView.deleteRows(at: removedIndexPaths, with: .automatic)
        }
        tableView.endUpdates()
    }

}

