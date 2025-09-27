import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let text: String
    let imageURL: String
    var votes: Int
    var comments: [String]
    var userVote: Int = 0 // 1 = upvote, -1 = downvote, 0 = no vote
}

struct HomeView: View {
    @State private var posts = [
        Post(
            text: "Eating carrots improves night vision",
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/7/70/CarrotRoots.jpg",
            votes: 3,
            comments: ["Interesting!", "I heard this before"]
        ),
        Post(
            text: "Vaccines cause autism",
            imageURL: "https://invalid-url-to-test.jpg", // invalid to test fallback
            votes: 1,
            comments: ["This is misleading"]
        )
    ]
    
    @State private var selectedPostIndex: Int? = nil
    @State private var newComment: String = ""
    @FocusState private var commentFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(posts.indices, id: \.self) { index in
                        PostCardView(
                            post: posts[index],
                            onUpvote: { handleVote(index: index, vote: 1) },
                            onDownvote: { handleVote(index: index, vote: -1) },
                            onOpenComments: {
                                selectedPostIndex = index
                                newComment = ""
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Feed")
            .sheet(
                isPresented: Binding(
                    get: { selectedPostIndex != nil },
                    set: { if !$0 { selectedPostIndex = nil } }
                )
            ) {
                if let i = selectedPostIndex {
                    NavigationView {
                        VStack(spacing: 12) {
                            // AsyncImage for comment sheet
                            AsyncImageWithFallback(urlString: posts[i].imageURL)
                                .frame(height: 160)
                                .clipped()
                            
                            Text(posts[i].text)
                                .font(.headline)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                            Divider()
                            
                            Text("Comments")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(posts[i].comments.indices, id: \.self) { cidx in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Text(String(posts[i].comments[cidx].prefix(1)))
                                                        .foregroundColor(.white)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("User")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Text(posts[i].comments[cidx])
                                                    .font(.body)
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 8) {
                                TextEditor(text: $newComment)
                                    .frame(minHeight: 44, maxHeight: 120)
                                    .padding(6)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                                    .focused($commentFieldFocused)
                                
                                Button(action: {
                                    let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    posts[i].comments.append(trimmed)
                                    newComment = ""
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .padding(10)
                                        .background(Circle().fill(Color.accentColor))
                                        .foregroundColor(.white)
                                }
                                .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding()
                        }
                        .navigationBarTitle("Reply", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { selectedPostIndex = nil }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    private func handleVote(index: Int, vote: Int) {
        withAnimation {
            var post = posts[index]
            if post.userVote == vote {
                post.votes -= vote
                post.userVote = 0
            } else {
                if post.userVote != 0 { post.votes -= post.userVote }
                post.votes += vote
                post.userVote = vote
            }
            posts[index] = post
        }
    }
}

// MARK: - Post Card View
struct PostCardView: View {
    let post: Post
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    let onOpenComments: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                AsyncImageWithFallback(urlString: post.imageURL)
                    .frame(height: 180)
                    .clipped()
                
                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 70)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            Text(post.text)
                .font(.headline)
                .lineLimit(3)
            
            HStack(spacing: 12) {
                Button(action: onUpvote) {
                    Image(systemName: "hand.thumbsup")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(post.userVote == 1 ? Color.green.opacity(0.3) : Color(.systemGray6))
                        )
                }
                
                Button(action: onDownvote) {
                    Image(systemName: "hand.thumbsdown")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(post.userVote == -1 ? Color.red.opacity(0.3) : Color(.systemGray6))
                        )
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("\(post.votes)")
                }
                .font(.subheadline.bold())
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(post.votes >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.12))
                )
                
                Button(action: onOpenComments) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.bubble")
                        Text("\(post.comments.count)")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 6)
    }
}

// MARK: - AsyncImage with fallback logic
struct AsyncImageWithFallback: View {
    let urlString: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                Color.gray.opacity(0.1).overlay(ProgressView())
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                // Try Picsum
                AsyncImage(url: URL(string: "https://picsum.photos/300/180")) { fallbackPhase in
                    switch fallbackPhase {
                    case .empty:
                        Color.gray.opacity(0.1)
                    case .success(let fallbackImage):
                        fallbackImage.resizable().scaledToFill()
                    case .failure:
                        // Fallback to system photo
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.gray.opacity(0.5))
                            .background(Color.gray.opacity(0.1))
                    @unknown default:
                        EmptyView()
                    }
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
