import SwiftUI

struct HomeView: View {
    @State private var quote: Quote?

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Your Mood Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .multilineTextAlignment(.center) 

                Spacer()

                if let quote = quote {
                    Text("“\(quote.content)”")
                        .font(.title)
                        .italic()
                        .padding()
                        .multilineTextAlignment(.center)

                    Text("- \(quote.author ?? "Unknown")")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                } else {
                    Text("Loading...")
                        .font(.title)
                        .padding()
                }

                Button(action: fetchRandomQuote) {
                    Text("New Quote")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Home")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.top, 40)
//                }
//            }
        }
        .onAppear(perform: fetchRandomQuote)
    }

    private func fetchRandomQuote() {
        QuoteService.shared.fetchRandomQuote { fetchedQuote in
            DispatchQueue.main.async {
                if let fetchedQuote = fetchedQuote {
                    self.quote = fetchedQuote
                } else {
                    self.quote = Quote(content: "Unable to load quote. Please try again.", author: nil)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
