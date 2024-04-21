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
    var filteredNodes: [TreeNode] = []
    @IBOutlet weak var searchBar: UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseJSONData()
        searchBar.delegate = self
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
    func filterNodes(for searchText: String) {
        if searchText.isEmpty {
            filteredNodes = rootNodes
        } else {
            filteredNodes = rootNodes.compactMap { filterNode($0, searchText) }
        }
        tableView.reloadData()
    }

    private func filterNode(_ node: TreeNode, _ searchText: String) -> TreeNode? {
        let filteredChildren = node.items.compactMap { filterNode($0, searchText) }
        if node.name.lowercased().contains(searchText.lowercased()) || !filteredChildren.isEmpty {
            let filteredNode = TreeNode(name: node.name, isExpanded: node.isExpanded, items: filteredChildren, parent: node.parent, depth: node.depth)
            filteredChildren.forEach { $0.parent = filteredNode }
            return filteredNode
        }
        return nil
    }

    
    func parseNode(_ json: [String: Any], parent: TreeNode? = nil, depth: Int = 0) -> TreeNode {
        // Parse the JSON dictionary to extract the node's name and items
        guard let name = json["name"] as? String,
              let items = json["items"] as? [[String: Any]] else {
            // If name or items are missing or not in the expected format, return a TreeNode with default values
            return TreeNode(name: "", isExpanded: false, items: [], parent: parent, depth: depth)
        }
        // Recursively parse the children nodes
        let children = items.map { parseNode($0, parent: TreeNode(name: name, isExpanded: false, items: [], parent: parent, depth: depth + 1), depth: depth + 1) }
        // Create and return a TreeNode with the parsed values
        return TreeNode(name: name, isExpanded: false, items: children, parent: parent, depth: depth)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchBarEmpty ? rootNodes.count : filteredNodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreeViewCell", for: indexPath) as! TreeViewCell
        let node: TreeNode
        if isSearchBarEmpty {
            node = rootNodes[indexPath.row]
        } else {
            node = filteredNodes[indexPath.row]
        }
        
        cell.nameLabel?.text = node.name
        cell.indentationLevel = node.depth // Set the indentation level
        cell.indentationWidth = 20 // Set the base indentation width
        
        if node.items.isEmpty {
            cell.disclosureButton?.isHidden = true
        } else {
            cell.disclosureButton?.isHidden = false
            let imageName = node.isExpanded ? "minus" : "plus"
            cell.disclosureButton?.setImage(UIImage(named: imageName), for: .normal)
            cell.disclosureButton?.tintColor = UIColor.red // Set your desired color here

        }
        

        cell.disclosureButtonTapAction = {
            self.toggleNode(at: indexPath)
        }
        
        // Adjust cell content indentation
        cell.contentView.frame.origin.x = CGFloat(node.depth) * cell.indentationWidth
        
        return cell
    }
    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    func toggleNode(at indexPath: IndexPath) {
        let node = isSearchBarEmpty ? rootNodes[indexPath.row] : filteredNodes[indexPath.row]
        node.isExpanded.toggle()

        // Begin table view updates
        tableView.beginUpdates()

        if node.isExpanded {
            insertChildren(of: node, at: indexPath)
        } else {
            removeChildren(of: node)
        }

        // End table view updates
        tableView.endUpdates()
    }


    func insertChildren(of parentNode: TreeNode, at indexPath: IndexPath) {
        var insertIndexPaths = [IndexPath]()
        let startIndex = indexPath.row + 1
        for (index, item) in parentNode.items.enumerated() {
            let insertIndex = startIndex + index
            if isSearchBarEmpty {
                rootNodes.insert(item, at: insertIndex)
            } else {
                if filteredNodes.firstIndex(where: { $0 === parentNode }) != nil {
                    filteredNodes.insert(item, at: insertIndex)
                }
            }
            insertIndexPaths.append(IndexPath(row: insertIndex, section: indexPath.section))
        }

        // Insert the children nodes into the appropriate array
        tableView.insertRows(at: insertIndexPaths, with: .automatic)
    }

    func removeChildren(of parentNode: TreeNode) {
        guard let parentIndex = isSearchBarEmpty ? rootNodes.firstIndex(where: { $0 === parentNode }) : filteredNodes.firstIndex(where: { $0 === parentNode }) else {
            return
        }

        var indexPathsToRemove = [IndexPath]()
        var removedRowCount = 0
        for (index, _) in parentNode.items.enumerated() {
            let rowIndexToRemove = parentIndex + 1 + removedRowCount
            indexPathsToRemove.append(IndexPath(row: rowIndexToRemove, section: 0))
            if isSearchBarEmpty {
                rootNodes.remove(at: rowIndexToRemove)
            } else {
                if let indexToRemove = filteredNodes.firstIndex(where: { $0 === parentNode.items[index] }) {
                    filteredNodes.remove(at: indexToRemove)
                }
            }
            removedRowCount += 1
        }

        // Remove the children nodes from the appropriate array
        tableView.deleteRows(at: indexPathsToRemove, with: .automatic)
    }








//    func toggleNode(at indexPath: IndexPath) {
//        let parentNode = isSearchBarEmpty ? rootNodes[indexPath.row] : filteredNodes[indexPath.row]
//        parentNode.isExpanded.toggle()
//
//        // Begin table view updates
//        tableView.beginUpdates()
//
//        if parentNode.isExpanded {
//            // Update your data source to include the children of the expanded node
//            let indexPaths = indexPathsForChildren(of: parentNode, startingAt: indexPath.row + 1)
//            if isSearchBarEmpty {
//                rootNodes.insert(contentsOf: parentNode.items, at: indexPath.row + 1)
//            } else {
//                filteredNodes.insert(contentsOf: parentNode.items, at: indexPath.row + 1)
//            }
//
//            // Insert the rows into the table view
//            tableView.insertRows(at: indexPaths, with: .automatic)
//        } else {
//            // Update your data source to remove the children of the collapsed node
//            let indexPaths = indexPathsForChildren(of: parentNode, startingAt: indexPath.row + 1)
//            if isSearchBarEmpty {
//                rootNodes.removeSubrange(indexPath.row + 1..<indexPath.row + 1 + parentNode.items.count)
//            } else {
//                filteredNodes.removeSubrange(indexPath.row + 1..<indexPath.row + 1 + parentNode.items.count)
//            }
//
//            // Delete the rows from the table view
//            tableView.deleteRows(at: indexPaths, with: .automatic)
//        }
//
//        // End table view updates
//        tableView.endUpdates()
//
//        // Smoothly reload visible rows
//        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
//        let updatedIndexPaths = Set(visibleIndexPaths).subtracting(Set([indexPath]))
//        tableView.reloadRows(at: Array(updatedIndexPaths), with: .automatic)
//    }
//    func indexPathsForChildren(of parentNode: TreeNode, startingAt startIndex: Int) -> [IndexPath] {
//        var indexPaths = [IndexPath]()
//        var index = startIndex
//        for _ in parentNode.items {
//            indexPaths.append(IndexPath(row: index, section: 0))
//            index += 1
//        }
//        return indexPaths
//    }

//This function is used to toggle the expansion state of a node in a tree-like structure displayed in a table view.
//    func toggleNode(at indexPath: IndexPath) {
//        // Get the node at the specified indexPath
//        let node = rootNodes[indexPath.row]
//        // Toggle the isExpanded property of the node
//        node.isExpanded.toggle()
//
//        // Begin table view updates
//        tableView.beginUpdates()
//
//        if node.isExpanded {
//            // Update your data source to include the children of the expanded node
//            rootNodes.insert(contentsOf: node.items, at: indexPath.row + 1)
//
//            // Set the parent for the inserted nodes
//            node.items.forEach { $0.parent = node }
//
//            // Create an array of index paths for the inserted rows
//            var indexPaths = [IndexPath]()
//            for i in 0..<node.items.count {
//                indexPaths.append(IndexPath(row: indexPath.row + 1 + i, section: indexPath.section))
//            }
//
//            // Insert the rows into the table view
//            tableView.insertRows(at: indexPaths, with: .automatic)
//        } else {
//            // Update your data source to remove the children of the collapsed node
//            var removedIndexPaths = [IndexPath]()
//            var removedNodes = [TreeNode]()
//
//            func removeChildren(for parentNode: TreeNode) {
//                for (index, item) in rootNodes.enumerated() {
//                    if let parent = item.parent, parent == parentNode {
//                        removedIndexPaths.append(IndexPath(row: index, section: indexPath.section))
//                        removedNodes.append(item)
//                        removeChildren(for: item)
//                    }
//                }
//            }
//
//            removeChildren(for: node)
//            rootNodes.removeAll(where: { removedNodes.contains($0) })
//
//            // Delete the rows from the table view
//            tableView.deleteRows(at: removedIndexPaths, with: .automatic)
//        }
//
//        // End table view updates
//        tableView.endUpdates()
//
//        // Smoothly reload visible rows
//        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
//        let updatedIndexPaths = Set(visibleIndexPaths).subtracting(Set([indexPath]))
//        tableView.reloadRows(at: Array(updatedIndexPaths), with: .automatic)
//    }

}
extension TreeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterNodes(for: searchText)
    }
}


