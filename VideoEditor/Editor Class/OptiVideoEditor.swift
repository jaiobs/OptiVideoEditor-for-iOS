//
//  OptiVideoEditor.swift
//  VideoEditor
//
//  Created by Optisol on 21/07/19.
//  Copyright © 2019 optisol. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos

class OptiVideoEditor: NSObject {
    
    //MARK: Add filter to video
    func addfiltertoVideo(strfiltername : String, strUrl : URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        //FilterName
        let filter = CIFilter(name:strfiltername)
        
        //Asset
        let asset = AVAsset(url: strUrl)
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("EffectVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //AVVideoComposition
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            
            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            filter?.setValue(source, forKey: kCIInputImageKey)
            
            // Crop the blurred output to the bounds of the original image
            let output = filter?.outputImage!.cropped(to: request.sourceImage.extent)
            
            // Provide the filter output to the composition
            request.finish(with: output!, context: nil)
            
        })
        
        //export the video to as per your requirement conversion
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputFileType = AVFileType.mov
        exportSession.outputURL = outputURL
        exportSession.videoComposition = composition
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                success(outputURL)
                
            case .failed:
                failure(exportSession.error?.localizedDescription)
                
            case .cancelled:
                failure(exportSession.error?.localizedDescription)
                
            default:
                failure(exportSession.error?.localizedDescription)
            }
        })
    }
    
    //MARK: crop the video which you select portion
    func trimVideo(sourceURL: URL, startTime: Double, endTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVAsset(url: sourceURL)
        _ = Float(asset.duration.value) / Float(asset.duration.timescale)
//        print("video length: \(length) seconds")
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("TrimVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //export the video to as per your requirement conversion
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: asset.duration.timescale),end: CMTime(seconds: endTime, preferredTimescale: asset.duration.timescale))
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                success(outputURL)
                
            case .failed:
                failure(exportSession.error?.localizedDescription)
                
            case .cancelled:
                failure(exportSession.error?.localizedDescription)
                
            default:
                failure(exportSession.error?.localizedDescription)
            }
        })
    }
    
    //MARK: crop the Audio which you select portion
    func trimAudio(sourceURL: URL, startTime: Double, stopTime: Double, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        /// Asset
        let asset = AVAsset(url: sourceURL)
//        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
//        print("video length: \(length) seconds")
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith:asset)
        
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {
            
            //Create Directory path for Save
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("TrimAudio")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).m4a")
            }catch let error {
                failure(error.localizedDescription)
            }
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the audio to as per your requirement conversion
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else{return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.m4a
            
            let range: CMTimeRange = CMTimeRangeFromTimeToTime(start: CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale), end: CMTimeMakeWithSeconds(stopTime, preferredTimescale: asset.duration.timescale))
            exportSession.timeRange = range
            
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    success(outputURL)
                    
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                    
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                    
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        }
    }
    
    func videoScaleAssetSpeed(fromURL url: URL,  by scale: Float64, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: url).asset
        
        // Composition Audio Video
        let mixComposition = AVMutableComposition()
        
        //TotalTimeRange
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        /// Video Tracks
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count == 0 {
            /// Can not find any video track
            return
        }
        
        /// Video track
        let videoTrack = videoTracks.first!
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        /// Audio Tracks
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if audioTracks.count > 0 {
            /// Use audio if video contains the audio track
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            /// Audio track
            let audioTrack = audioTracks.first!
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
                let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
                
                compositionAudioTrack?.preferredTransform = audioTrack.preferredTransform
                
            } catch _ {
                /// Ignore audio error
            }
        }
        
        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
            
            /// Keep original transformation
            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
            
            //Create Directory path for Save
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("SpeedVideo")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
            }catch let error {
                failure(error.localizedDescription)
            }
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the video to as per your requirement conversion
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed :
                        success(outputURL)
                    case .failed:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    case .cancelled:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    default:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    }
                })
            } else {
                failure(nil)
            }
        } catch {
            // Handle the error
            failure("Inserting time range failed.")
        }
        
    }
    
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        //Audio & Video Asset
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        //Audio video track Mix composition
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)
            
            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                    try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                    
                } catch{
                    failure(error.localizedDescription)
                }
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration)
            }
        }
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 1920, height: 1080) //(720, 480), (1920,1080)
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("MergeVideowithAudio")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //export the video to as per your requirement conversion
        if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed :
                    success(outputURL)
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        } else {
            failure("video export session failed")
        }
    }
    

    func mergeTwoVideosArry(arrayVideos:[AVAsset], success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 3)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = CMTime.zero
        
        for videoAsset in arrayVideos {
            try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("MergeTwoVideos")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //export the video to as per your requirement conversion
        if let exportSession = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed :
                    success(outputURL)
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        } else {
            failure("video export session failed")
        }
    }
    
    func transitionAnimation(videoUrl: URL, animation:Bool, type: Int, playerSize: CGRect,success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        var insertTime = CMTime.zero
        var arrayLayerInstructions:[AVMutableVideoCompositionLayerInstruction] = []
        var outputSize = CGSize(width: 0, height: 0)
        
        let aVideoAsset = AVAsset(url: videoUrl)
        
        // Determine video output size
        
        let videoTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        
        let assetInfo = self.orientationFromTransform(videoTrack.preferredTransform)
        
        var videoSize = videoTrack.naturalSize
        if assetInfo.isPortrait == true {
            videoSize.width = videoTrack.naturalSize.height
            videoSize.height = videoTrack.naturalSize.width
        }
        
        if videoSize.height > outputSize.height {
            outputSize = videoSize
        }
        
        
        if outputSize.width == 0 || outputSize.height == 0 {
            outputSize = defaultSize
        }
        
        // Init composition
        let mixComposition = AVMutableComposition()
        
        // Get video track
        guard let videoTrackk = aVideoAsset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        
        // Get audio track
        var audioTrack:AVAssetTrack?
        //  if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
        audioTrack = aVideoAsset.tracks(withMediaType: AVMediaType.audio).first
        /* }
         else {
         audioTrack = silenceSoundTrack
         }*/
        
        // Init video & audio composition track
        let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        do {
            let startTime = CMTime.zero
            let duration = aVideoAsset.duration
            
            // Add video track to video composition at specific time
            try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration),
                                                       of: videoTrackk,
                                                       at: insertTime)
            
            // Add audio track to audio composition at specific time
            if let audioTrack = audioTrack {
                try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration), of: audioTrack, at: insertTime)
            }
            
            // Add instruction for video track
            let layerInstruction = self.videoCompositionInstructionForTrackWithSizeandTime(track: videoCompositionTrack!, asset: aVideoAsset, standardSize: outputSize, atTime: insertTime)
            
            // Hide video track before changing to new track
            let endTime = CMTimeAdd(insertTime, duration)
            
            //if animation {
            let timeScale = aVideoAsset.duration.timescale
            let durationAnimation = CMTime.init(seconds: 1, preferredTimescale: timeScale)
            
            // layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange.init(start: endTime, duration: durationAnimation))
            switch type {
            case 0:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 500, y: 0), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 1:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: -500, y: 0), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 2:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 0, y: -600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 3:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 0, y: 600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 4:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: -600, y: -600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 5:
                layerInstruction.setTransformRamp(fromStart: CGAffineTransform(translationX: 600, y: 600), toEnd: CGAffineTransform(translationX: 0, y: 0), timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            case 6:
                layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: CMTimeRange.init(start: CMTime.zero, duration: durationAnimation))
            default:
                break
            }
            layerInstruction.setOpacity(1, at: endTime)
            arrayLayerInstructions.append(layerInstruction)
            insertTime = CMTimeAdd(insertTime, duration)
        }
        catch {
            failure(error.localizedDescription)
        }
        
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = outputSize
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("TransitionVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //export the video to as per your requirement conversion
        if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.videoComposition = mainComposition
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed :
                    success(outputURL)
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        } else {
            failure("video export session failed")
        }
    }
    
    
    func addStickerorTexttoVideo(videoUrl: URL, watermarkText text : String, imageName name : String, position : Int,  success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: videoUrl).asset
        
        // Create an AVMutableComposition for editing
        let mutableComposition = getVideoComposition(asset: asset)
        
        let videoSizeone = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
        let videoWidth = videoSizeone.width
        let videoHeight = videoSizeone.height
        
        // Create a CALayer instance and configurate it
        let parentLayer = CALayer()
        if name != "" {
            let stickerLayer = CALayer()
            stickerLayer.contents = UIImage(named: name)?.cgImage
            stickerLayer.contentsGravity = CALayerContentsGravity.resizeAspect
            let stickerWidth = videoWidth / 6
            let stickerX = videoWidth * CGFloat(5 * (position % 3)) / 12
            let stickerY = videoHeight * CGFloat(position / 3) / 3
            stickerLayer.frame = CGRect(x: stickerX, y: stickerY, width: stickerWidth, height: stickerWidth)
            stickerLayer.opacity = 0.9
            parentLayer.addSublayer(stickerLayer)
        } else if text != "" {
            let textLayer = CATextLayer()
            textLayer.string = text
            textLayer.font = UIFont(name: "Maple-Regular.otf", size: 40) ?? UIFont.systemFont(ofSize: 40)
            
            if position % 3 == 0 {
                textLayer.alignmentMode = CATextLayerAlignmentMode.left
            } else if position % 3 == 1 {
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
            } else {
                textLayer.alignmentMode = CATextLayerAlignmentMode.right
            }
            
            let textWidth = videoWidth / 5
            let textX = videoWidth * CGFloat(5 * (position % 3)) / 12
            let textY = videoHeight * CGFloat(position / 3) / 3
            textLayer.frame = CGRect(x: textX , y: textY + 20, width: textWidth, height: 50)
            textLayer.opacity = 0.6
            parentLayer.addSublayer(textLayer)
        }
        
        let videoTrack: AVAssetTrack = mutableComposition.tracks(withMediaType: AVMediaType.video)[0]
        let videoSizetwo = videoTrack.naturalSize
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
        
        let containerLayer = CALayer()
        containerLayer.frame = CGRect(x: 0, y: 0, width: videoSizetwo.width, height: videoSizetwo.height)
        containerLayer.addSublayer(videoLayer)
        containerLayer.addSublayer(parentLayer)
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layerComposition.renderSize = videoSizetwo
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: containerLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mutableComposition.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        layerComposition.instructions = [instruction]
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("StickerVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //export the video to as per your requirement conversion
        if let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.videoComposition = layerComposition
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed :
                    success(outputURL)
                case .failed:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                case .cancelled:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                default:
                    if let _error = exportSession.error?.localizedDescription {
                        failure(_error)
                    }
                }
            })
        } else {
            failure("video export session failed")
        }
    }
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrackWithSizeandTime(track: AVCompositionTrack, asset: AVAsset, standardSize:CGSize, atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var aspectFillRatio:CGFloat = 1
        if assetTrack.naturalSize.height < assetTrack.naturalSize.width {
            aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
        }
        else {
            aspectFillRatio = standardSize.width / assetTrack.naturalSize.width
        }
        
        if assetInfo.isPortrait {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            let posX = standardSize.width/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: atTime)
            
        } else {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }
            instruction.setTransform(concat, at: atTime)
        }
        return instruction
    }
    
    func getVideoComposition(asset : AVAsset) -> AVMutableComposition {
        // Create an AVMutableComposition for editing
        let mutableComposition = AVMutableComposition()
        // Get video tracks and audio tracks of our video and the AVMutableComposition
        let compositionVideoTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 3)

        let compositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let videoTrack: AVAssetTrack  = asset.tracks(withMediaType: AVMediaType.video)[0]
        let audioTrack: AVAssetTrack  = asset.tracks(withMediaType: AVMediaType.audio)[0]
        
        // Add our video tracks and audio tracks into the Mutable Composition normal order
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: videoTrack, at: CMTime.zero)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: audioTrack, at: CMTime.zero)
        } catch {
            return AVMutableComposition()
        }
        
        return mutableComposition
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = sourceType
        mediaUI.mediaTypes = [kUTTypeMovie as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        delegate.present(mediaUI, animated: true, completion: nil)
    }
    
    //MARK: Thumbnail Image generate
    func generateThumbnail(path: URL) -> UIImage? {
        // getting image from video
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            OptiToast.showNegativeMessage(message: error.localizedDescription)
            return nil
        }
    }
    //MARK : add filter to video placeholder image
    func convertImageToBW(filterName : String ,image:UIImage) -> UIImage {
        
        let filter = CIFilter(name: filterName)
        
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: image)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        
        return UIImage(cgImage: cgImage!)
    }
    //MARK : Create album inside photos library
    func createAlbum(withTitle title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            var placeholder: PHObjectPlaceholder?
            
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { (created, error) in
                var album: PHAssetCollection?
                if created {
                    UserDefaults.standard.set(true, forKey: "AlbumCreated")
                    let collectionFetchResult = placeholder.map { PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [$0.localIdentifier], options: nil) }
                    album = collectionFetchResult?.firstObject
                }
                completionHandler(album)
            })
        }
    }
    //MARK : get album inside photos library
    func getAlbum(title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", title)
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let album = collections.firstObject {
                completionHandler(album)
            } else {
                self?.createAlbum(withTitle: title, completionHandler: { (album) in
                    completionHandler(album)
                })
            }
        }
    }
    //MARK : save video inside photos library same album name
    func save(videoUrl: URL, toAlbum titled: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        getAlbum(title: titled) { (album) in
            DispatchQueue.global(qos: .background).async {
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
                    let assets = assetRequest?.placeholderForCreatedAsset
                        .map { [$0] as NSArray } ?? NSArray()
                    let albumChangeRequest = album.flatMap { PHAssetCollectionChangeRequest(for: $0) }
                    albumChangeRequest?.addAssets(assets)
                }, completionHandler: { (success, error) in
                    completionHandler(success, error)
                })
            }
        }
    }
}
