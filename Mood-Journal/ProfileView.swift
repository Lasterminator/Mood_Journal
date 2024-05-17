import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var globalData: GlobalData
    @State private var userName: String = "User Name"
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Spacer()

                if isEditing {
                    // Editable Profile Image
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 150, height: 150)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }

                    // Editable User Name
                    TextField("Enter your name", text: $userName)
                        .font(.title)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // Save Button
                    Button(action: {
                        isEditing.toggle()
                        // Save action if necessary
                    }) {
                        Text("Save")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                } else {
                    // Non-editable Profile Image
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 150, height: 150)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    }

                    // Non-editable User Name
                    Text(userName)
                        .font(.title)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "Cancel" : "Edit")
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(GlobalData())
}
