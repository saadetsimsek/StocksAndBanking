//
//  HapticsManager.swift
//  StocksAndBanking
//
//  Created by Saadet Şimşek on 09/01/2024.
//

import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {
        
    }
    
    //MARK: - Public
    
    public func vibrateForSelection(){
        //vibrate lightly for a selection tap interaction
        let generator = UISelectionFeedbackGenerator() // bu sınıf geri bildirim titremesi sağlıyo
        generator.prepare()
        generator.selectionChanged()
    }
    
    ///Play haptic for given type interaction
    /// - Parameter type: Type to vibrate for
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
 /*   public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
          // Bildirim geri bildirimi için bir jeneratör oluştur
          let generator = UINotificationFeedbackGenerator()
          generator.prepare()
          generator.notificationOccurred(type)
      }
  */
}
