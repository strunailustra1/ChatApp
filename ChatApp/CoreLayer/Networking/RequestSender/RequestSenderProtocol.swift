//
//  RequestProtocol.swift
//  ChatApp
//
//  Created by Наталья Мирная on 18.11.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation

struct RequestConfig<Parser> where Parser: ParserProtocol {
    let session: SessionProtocol
    let request: RequestProtocol
    let parser: Parser
}

protocol RequestSenderProtocol {
    func send<Parser>(requestConfig: RequestConfig<Parser>,
                      completionHandler: @escaping(Result<Parser.Model, Error>) -> Void)
}
