//
//  ContentView.swift
//  AI Chatbot
//
//  Created by Arslan Kamchybekov on 6/16/23.
//  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

import SwiftUI
import Combine

struct ContentView: View {
    @State var chatMessages: [ChatMessage] = []
    @State private var isButtonEnabled = false
    @State var messageText = ""
    @State var cancellables = Set<AnyCancellable>()
    let openAIService = OpenAIService()
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack {
                    ForEach(chatMessages, id: \.id){ message in
                        messageView(message: message)
                    }
                }
            }
            HStack{
                TextField("Enter a message", text: $messageText)
                    .foregroundColor(.black)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                    .onChange(of: messageText){ text in
                        isButtonEnabled = !text.isEmpty
                    }
                            
                Button("Send") {
                    sendMessage()
                }
                .padding()
                .disabled(!isButtonEnabled)
                .foregroundColor(.white)
                .background(isButtonEnabled ? .black : .gray)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    func messageView(message: ChatMessage) -> some View{
        HStack{
            if message.sender == .me { Spacer() }
            Text(message.content)
                .foregroundColor(message.sender == .me ? .white : .black)
                .padding()
                .background(message.sender == .me ? .blue : .gray.opacity(0.2))
                .cornerRadius(16)
            if message.sender == .gpt { Spacer() }
        }
    }
    
    func sendMessage(){
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessages(message: messageText).sink { completion in
            //Error handling
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text else { return }
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            chatMessages.append(gptMessage)
        }
        .store(in: &cancellables)
        messageText = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ChatMessage{
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender{
    case me
    case gpt
}

extension ChatMessage{
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "Sample message", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sample gpt", dateCreated: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "Sample message", dateCreated: Date(), sender: .me)
    ]
}


