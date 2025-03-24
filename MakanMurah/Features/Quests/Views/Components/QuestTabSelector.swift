import SwiftUI

struct QuestTabSelector: View {
    @Binding var selectedTab: Int
    @Namespace private var tabAnimation
    let questTypes = QuestType.allCases
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    TabButton(
                        title: "All Quests",
                        isSelected: selectedTab == 0,
                        namespace: tabAnimation,
                        action: { selectedTab = 0 }
                    )
                    .id(0)
                    
                    ForEach(0..<questTypes.count, id: \.self) { index in
                        TabButton(
                            title: questTypes[index].rawValue,
                            isSelected: selectedTab == index + 1,
                            namespace: tabAnimation,
                            action: { selectedTab = index + 1 }
                        )
                        .id(index + 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: selectedTab) { _, newValue in
                withAnimation {
                    scrollProxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

