//
//  ImageLoader.swift
//  Chat_App
//
//  Created by MACPC on 25/01/24.
//

import UIKit

class ImageLoader {

    static let cache = NSCache<NSString , UIImage>()

    class func loadImageUsingURLWithCache(url : URL , completion : @escaping (UIImage?) -> Void){
//        Check if Image is in the cache
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString){
            return
        }

//        If not , downlaod the Image
        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = error {
                print("Error, \(error)")
                completion(nil)
                return
            }

            guard let data = data , let image = UIImage(data: data) else {
                completion(nil)
                return
            }

//            Store the downloaded image in the cache
            cache.setObject(image , forKey: url.absoluteString as NSString)

//            return the Image
            completion(image)

        }.resume()
    }
//
}
