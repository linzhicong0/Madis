//
//  DatabaseNavigationController.swift
//  Madis
//
//  Created by Jack Lin on 2024/4/17.
//

import SwiftUI

// for testing perpose
struct Graphic: Identifiable, Hashable {
    var id = UUID()
    var imageName: String
    var text: String
    var children: [Graphic]
    
    
    init(id: UUID = UUID(), imageName: String, text: String, children: [Graphic]) {
        self.id = id
        self.imageName = imageName
        self.text = text
        self.children = children
    }
}

class DatabaseNavigationController: NSViewController {
    
    var outlineView: NSOutlineView!
    var scrollView: NSScrollView!
    
    let rowHeight: CGFloat = 22
    
    override func loadView() {
        
        // setup the scroll view
        self.scrollView = NSScrollView()
        self.scrollView.scrollerStyle = .overlay
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        self.scrollView.hasVerticalScroller = true
        
        
        // setup the outlineView
        self.outlineView = NSOutlineView()
        self.view = scrollView
        self.outlineView.dataSource = self
        self.outlineView.headerView = nil
        self.outlineView.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClick)
        
        let column  = NSTableColumn(identifier: .init("Cell"))
        column.title = "Cell"
        self.outlineView.addTableColumn(column)
        self.outlineView.autoresizingMask=[.height, .width]
        self.outlineView.expandItem(outlineView.item(atRow: 0))
        
        self.scrollView.documentView = outlineView
    }
    @objc
    private func onItemDoubleClick() {
        
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? Graphic else { return }
        
        if item.children.count > 0 {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        }
    }
}


extension DatabaseNavigationController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let node = item as? RedisDatabase {
            let item = DatabaseRowView(name: node.name)
            let hostingView = NSHostingView(rootView: item)
            return hostingView
        }
        else if let node = item as? RedisRow {
            let item = DatabaseRowView(name: node.key)
            let hostingView = NSHostingView(rootView: item)
            return hostingView
        }
        
        return nil
    }
    
    // change the row height
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return self.rowHeight
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        true
    }
    
}

extension DatabaseNavigationController: NSOutlineViewDataSource {
    // the count of the item
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let node = item as? RedisDatabase {
            return node.numOfKeys
        }
        return MockData.database.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if let node = item as? RedisDatabase {
            return node.rows[index]
        }
        return MockData.database[index]
        
    }
    
    // if the item can expand
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? RedisDatabase {
            return !item.rows.isEmpty
        }
        return false
    }
    
}
