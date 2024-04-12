//
//  TreeNode.swift
//  TreeTable
//
//  Created by Nagender Kumar on 12/04/24.
//

class TreeNode: Equatable {
    var name: String
    var isExpanded: Bool
    var items: [TreeNode]
    weak var parent: TreeNode?
    var depth: Int // Add depth property

    init(name: String, isExpanded: Bool, items: [TreeNode], parent: TreeNode? = nil, depth: Int) {
        self.name = name
        self.isExpanded = isExpanded
        self.items = items
        self.parent = parent
        self.depth = depth
    }

    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        return lhs.name == rhs.name && lhs.isExpanded == rhs.isExpanded && lhs.items == rhs.items && lhs.parent === rhs.parent
    }
}
