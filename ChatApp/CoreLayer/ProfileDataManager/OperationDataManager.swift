//
//  OperationManager.swift
//  ChatApp
//
//  Created by Наталья Мирная on 12.10.2020.
//  Copyright © 2020 Наталья Мирная. All rights reserved.
//

import Foundation
import UIKit

class OperationDataManager: ProfileDataManagerProtocol {
    
    private let queue: OperationQueue
    
    init() {
        queue = OperationQueue()
    }
    
    func save(profile: Profile, changedFields: ProfileChangedFields,
              succesfullCompletion: @escaping() -> Void, errorCompletion: @escaping() -> Void) {
        
        var operations = [Operation]()
        
        let resultOperation = SaveResultOperation()
        resultOperation.succesfullCompletion = succesfullCompletion
        resultOperation.errorCompletion = errorCompletion
        operations.append(resultOperation)
        
        if changedFields.profileImageChanged {
            let saveImageOperation = SaveImageOperation()
            saveImageOperation.profile = profile
            operations.append(saveImageOperation)
            resultOperation.addDependency(saveImageOperation)
        }
        
        if changedFields.fullnameChanged {
            let saveFullnameOperation = SaveFullnameOperation()
            saveFullnameOperation.profile = profile
            operations.append(saveFullnameOperation)
            resultOperation.addDependency(saveFullnameOperation)
        }
        
        if changedFields.descriptionChanged {
            let saveDescriptionOperation = SaveDescriptionOperation()
            saveDescriptionOperation.profile = profile
            operations.append(saveDescriptionOperation)
            resultOperation.addDependency(saveDescriptionOperation)
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    func fetch(defaultProfile: Profile, succesfullCompletion: @escaping(Profile) -> Void) {
        var operations = [Operation]()
        
        let fetchImageOperation = FetchImageOperation()
        operations.append(fetchImageOperation)
        
        let fetchFullnameOperation = FetchFullnameOperation()
        operations.append(fetchFullnameOperation)
        
        let fetchDescriptionOperation = FetchDescriptionOperation()
        operations.append(fetchDescriptionOperation)
        
        let fetchResultOperation = FetchResultOperation()
        fetchResultOperation.succesfullCompletion = succesfullCompletion
        fetchResultOperation.defaultProfile = defaultProfile
        fetchResultOperation.addDependency(fetchImageOperation)
        fetchResultOperation.addDependency(fetchFullnameOperation)
        fetchResultOperation.addDependency(fetchDescriptionOperation)
        operations.append(fetchResultOperation)
        
        queue.addOperations(operations, waitUntilFinished: false)
    }
}

class SaveImageOperation: Operation, OperationWithBooleanResult {
    var result: Bool = false
    var profile: Profile?
    
    override func main() {
        if let newImage = profile?.profileImage,
            let newImageData = newImage.jpegData(compressionQuality: 1) ?? newImage.pngData() {
            do {
                try newImageData.write(to: ProfilePath.image.getURL())
                result = true
            } catch {}
        }
    }
}

class SaveFullnameOperation: Operation, OperationWithBooleanResult {
    var result: Bool = false
    var profile: Profile?
    
    override func main() {
        do {
            try profile?.fullname.write(to: ProfilePath.fullname.getURL(),
                                        atomically: true,
                                        encoding: String.Encoding.utf8)
            result = true
        } catch {}
    }
}

class SaveDescriptionOperation: Operation, OperationWithBooleanResult {
    var result: Bool = false
    var profile: Profile?
    
    override func main() {
        do {
            try profile?.description.write(to: ProfilePath.description.getURL(),
                                           atomically: true,
                                           encoding: String.Encoding.utf8)
            result = true
        } catch {}
    }
}

class SaveResultOperation: Operation {
    var chainResult: Bool {
        var result = true
        for dependency in dependencies {
            let operation = dependency as? OperationWithBooleanResult
            if !(operation?.result ?? false) {
                result = false
            }
        }
        return result
    }
    
    var succesfullCompletion: (() -> Void)?
    var errorCompletion: (() -> Void)?
    
    override func main() {
        OperationQueue.main.addOperation {
            self.chainResult ? self.succesfullCompletion?() : self.errorCompletion?()
        }
    }
}

class FetchImageOperation: Operation {
    var result: UIImage?
    
    override func main() {
        result = try? UIImage(data: Data(contentsOf: ProfilePath.image.getURL()))
    }
}

class FetchFullnameOperation: Operation {
    var result: String?
    
    override func main() {
        result = try? String(contentsOf: ProfilePath.fullname.getURL(), encoding: .utf8)
    }
}

class FetchDescriptionOperation: Operation {
    var result: String?
    
    override func main() {
        result = try? String(contentsOf: ProfilePath.description.getURL(), encoding: .utf8)
    }
}

class FetchResultOperation: Operation {
    var defaultProfile: Profile?
    var succesfullCompletion: ((Profile) -> Void)?
    
    override func main() {
        var image = defaultProfile?.profileImage
        var fullname = defaultProfile?.fullname
        var description = defaultProfile?.description
        
        for dependency in dependencies {
            if let operation = dependency as? FetchImageOperation, let fetchedData = operation.result {
                image = fetchedData
                continue
            }
            
            if let operation = dependency as? FetchFullnameOperation, let fetchedData = operation.result {
                fullname = fetchedData
                continue
            }
            
            if let operation = dependency as? FetchDescriptionOperation, let fetchedData = operation.result {
                description = fetchedData
                continue
            }
        }
        
        let profile = Profile(fullname: fullname ?? "",
                              description: description ?? "",
                              profileImage: image ?? nil)
        
        OperationQueue.main.addOperation {
            self.succesfullCompletion?(profile)
        }
    }
}

protocol OperationWithBooleanResult {
    var result: Bool { get }
}
