//
//  ContentView.swift
//  GenericSwipes
//
//  Created by Alexander on 07/10/2021.
//

import SwiftUI

struct MyModel {
    let id: String = UUID().uuidString
    let name: String
    
    
    static var dummy: [MyModel] {
        [
            MyModel(name: "Xyi0"),
            MyModel(name: "Xyi1"),
            MyModel(name: "Xyi2"),
            MyModel(name: "Xyi3"),
            MyModel(name: "Xyi4"),
            MyModel(name: "Xyi5"),
            MyModel(name: "Xyi6")
        ]
    }
}

// TODO: for swipes
// actions
// model
// view

struct ContentView: View {
    
    @State var models: [MyModel] = MyModel.dummy
    
    func createRightSwipes(item: MyModel) -> [Swipe] {
        [
            Swipe(title: "Text", tintColor: .white, image: Image(systemName: "square.and.arrow.up"), backgroundColor: .red, size: .init(width: 100, height: 100), type: .leading, action: { print("action this action that funckkkkkk \(item.id.uppercased())") }),
            Swipe(title: "Text1", tintColor: .white, image: Image(systemName: "trash"), backgroundColor: .blue, size: .init(width: 100, height: 100), type: .leading, action: { print("action this action that funckkkkkk \(item.name.uppercased())") })
        ]
    }
    
    var body: some View {
        NettellerSuiList {
            ForEach(self.models, id: \.id) { item in
                let actions = self.createRightSwipes(item: item)
                NettellerSwipes(model: item, swipes: actions) {
                    MyModelCell(item: item)
                        .background(Color.gray)
                }
            }
        }
    }
}

struct MyModelCell: View {
    
    var item: MyModel
    
    var body: some View {
        VStack {
            Spacer()
            Text(item.name)
            Spacer()
            Divider()
        }.frame(height: 100)
    }
}

struct Swipe {
    var id: String = UUID().uuidString
    var title: String?
    var tintColor: Color?
    var image: Image
    var backgroundColor: Color?
    var size: CGSize?
    var type: SwipeType
    var action: () -> Void

    enum SwipeType {
        case leading
        case trailing
    }

}

struct NettellerSwipes<T, Content>: View where Content: View {
    
    let model: T
    let swipes: [Swipe]
    let content: Content
    
    @GestureState private var longDragDetected: Bool = false
    @State private var cellOffset: CGFloat = 0
    
    init(model: T, swipes: [Swipe], @ViewBuilder content: () -> Content) {
        self.model = model
        self.swipes = swipes
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(self.swipes, id: \.id) { item in
                    if item.type == .leading {
                        SwipeActionView(swipe: item)
                    }
                }
                Spacer()
                ForEach(self.swipes, id: \.id) { item in
                    if item.type == .trailing {
                        SwipeActionView(swipe: item)
                    }
                }
            }
            let _ = print("Offset: \(self.cellOffset)")
            self.content
                .offset(x: self.cellOffset)
                .simultaneousGesture(DragGesture().updating(self.$longDragDetected, body: { value, state, transaction in
                    DispatchQueue.main.async {
                        if value.translation.width > 0 {
                            let swipes = self.swipes.filter({ $0.type == .leading })
                            let actionsWidth = (swipes.first?.size?.width ?? 30) * CGFloat(swipes.count)
                            print("Translation: ", value.translation.width, "GestureState: ", self.longDragDetected)
                            if value.translation.width > actionsWidth {
                                self.cellOffset = actionsWidth
                            } else {
                                self.cellOffset = swipes.isEmpty ? 0 : value.translation.width
                            }
                        } else if value.translation.width < 0 {
                            let swipes = self.swipes.filter({ $0.type == .trailing })
                            let actionsWidth = (swipes.first?.size?.width ?? 30) * CGFloat(swipes.count)
                            if value.translation.width < -actionsWidth {
                                self.cellOffset = -actionsWidth
                            } else {
                                self.cellOffset = swipes.isEmpty ? 0 : value.translation.width
                            }
                        } else {
                            self.cellOffset = 0
                        }
                    }
                }).onEnded({ value in
                    if value.translation.width > 0 {
                        let swipes = self.swipes.filter({ $0.type == .leading })
                        let actionsWidth = (swipes.first?.size?.width ?? 30) * CGFloat(swipes.count)
                        print("ActionsWidth: ", actionsWidth)
                        if value.translation.width > actionsWidth / 2 {
                            print("going to alllllll action width")
                            self.cellOffset = actionsWidth
                        } else {
                            print("going to zero")
                            self.cellOffset = 0
                        }
                        
                    } else if value.translation.width < 0 {
                        let swipes = self.swipes.filter({ $0.type == .trailing })
                        let actionsWidth = (swipes.first?.size?.width ?? 30) * CGFloat(swipes.count)
                        print("on ended actions width: ", actionsWidth)
                        if value.translation.width < (-actionsWidth) / 2 {
                            self.cellOffset = -actionsWidth
                        } else {
                            self.cellOffset = 0
                        }
                        
                    } else {
                        self.cellOffset = 0
                    }
                }))
                .animation(.linear)
        }
    }
    
}

struct SwipeActionView: View {
    
    var swipe: Swipe
    
    var body: some View {
        Button(action: swipe.action) {
            VStack {
                if let title = self.swipe.title {
                    Text(title)
                }
                if let image = self.swipe.image {
                    image
                }
            }
            .frame(width: self.swipe.size?.width ?? 30, height: self.swipe.size?.height ?? 30)
            .foregroundColor(self.swipe.tintColor ?? .white)
            .background(self.swipe.backgroundColor ?? .blue)
        }
    }
}


public struct NettellerSuiList<Content>: View where Content: View {
    
    private var content: Content
    var ignoreSageArea: Bool = true
    var scrollingIndicator: Bool = false
    private var spacing: CGFloat = 0
    
    public init(spacing: CGFloat = 0, ignoreSafeArea: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.spacing = spacing
        self.ignoreSageArea = ignoreSafeArea
    }
    
    public var body: some View {
        if self.ignoreSageArea {
            ScrollView(.vertical, showsIndicators: self.scrollingIndicator) {
                VStack(spacing: self.spacing) {
                    self.content
                }
            }.edgesIgnoringSafeArea(.leading)
        } else {
            ScrollView(.vertical) {
                VStack(spacing: self.spacing) {
                    self.content
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
