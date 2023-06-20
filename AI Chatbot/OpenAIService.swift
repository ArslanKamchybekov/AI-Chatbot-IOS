//
//  OpenAIService.swift
//  AI Chatbot
//
//  Created by Arslan Kamchybekov on 6/18/23.
//

import Foundation
import Alamofire
import Combine

class OpenAIService{
    let baseUrl = "https://api.openai.com/v1/"
    
    func sendMessages(message: String) -> AnyPublisher<OpenAICompletionsResponse, Error>{
        let body = OpenAICompletionsBody(model: "text-davinci-003", prompt: message, temperature: 0.7)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            AF.request(self.baseUrl + "completions", method: .post, parameters: body, encoder: .json, headers: headers)
                .responseDecodable(of: OpenAICompletionsResponse.self) { response in
                    switch response.result{
                    case .success(let result):
                        promise(.success(result))
                    case .failure(let error):
                        promise(.failure(error))
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}

struct OpenAICompletionsBody: Encodable{
    let model: String
    let prompt: String
    let temperature: Float?
}

struct OpenAICompletionsResponse: Decodable{
    let id: String
    let choices: [OpenAICompletionChoice]
}

struct OpenAICompletionChoice: Decodable{
    let text: String
}
