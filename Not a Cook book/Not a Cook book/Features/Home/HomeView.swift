import SwiftUI

struct HomeView: View {
    // Your images + titles
    let foods = [
        ("Burger", "Burger"),
        ("Pasta", "Pasta"),
        ("Steak", "Steak"),
        ("Lasagna", "Lasagna"),
        ("Doner", "Doner"),
        ("Pizza", "Pizza")
    ]
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title
                    Text("What are you going to eat Today?!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    
                    // 2x2 Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(foods, id: \.0) { food in
                            VStack {
                                Image(food.1)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
