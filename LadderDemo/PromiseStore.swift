//
//  PromiseStore.swift
//  LadderDemo
//
//  Created by Richard Melpignano on 6/2/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import Foundation

class PromiseStore {
    
    var allPromises = [Promise]()
    
    @discardableResult func createPromise(content: String) -> Promise {
        
        let newPromise = Promise(content: content)
        allPromises.append(newPromise)
        
        return newPromise
    }
    
    func removePromise(_ promise: Promise) {
        
        if let index = allPromises.index(of: promise) {
            allPromises.remove(at: index)
        }
    }
}
