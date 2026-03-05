import SwiftUI


struct TabRow: View {
    @Binding var tab: TabItem
    
    var body: some View {
        HStack {
            Text(tab.displayName)
                .foregroundStyle(Color.secondary)
            Spacer()
            Button(action: {
                tab.toggleFavorite()
            }, label: {
                Image(systemName: tab.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(tab.isFavorite ? Color.yellow : Color.secondary)
                    .font(.system(size: 20))
            })
        }
    }
}
