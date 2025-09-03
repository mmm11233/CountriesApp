import SwiftUI

struct CountriesListView: View {
    @StateObject private var viewModel = CountriesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: {
                            viewModel.retry()
                        }) {
                            Text("Retry")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                
                List {
                    ForEach(viewModel.countries) { country in
                        VStack(alignment: .leading) {
                            Text(country.name)
                                .font(.headline)
                            Text("Currencies: \(country.currencyCodes.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .onAppear {
                            if let index = viewModel.countries.firstIndex(of: country),
                               index >= viewModel.countries.count - 4 {
                                viewModel.fetchNextPageWithDelay()
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Countries")
            .onAppear {
                if viewModel.countries.isEmpty {
                    viewModel.fetchCountries()
                }
            }
        }
    }
}



#Preview {
    CountriesListView()
}
