//
//  ViewController.swift
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
import MediaPlayer


class OptiViewController: UIViewController {
    
    // Variable Declartion
    var pickedFileName : String = ""
    var selectedIndex = 0
    var selectedRow = 0
    var thumImg: UIImage?
    var slctVideoUrl: URL?
    var slctAudioUrl: URL?
    var isloadFirstVideo = 0
    var audioAsset: AVAsset?
    var filterSelcted = 100
    var assetArray = [AVAsset]()
    var avplayer = AVPlayer()
    var playerController = AVPlayerViewController()
    var activeField: UITextField?
    
    var isMergeClicked = false
    var isSliderEnd = true
    
    var cropsliderminimumValue : Double = 0.0
    var cropslidermaximumValue : Double = 0.0
    var mergesliderminimumValue : Double = 0.0
    var mergeslidermaximumValue : Double = 0.0
    var videoPlaybackPosition: CGFloat = 0.0
    
    var videoTotalsec = 0.0
    var audioTotalsec = 0.0
    var strSelectedEffect = ""
    var strSelectedSpeed = ""
    var strSelectedSticker = ""
    var selectedTransitionType = -1
    var selectedStickerPosition = -1
    var selectedTextPosition = -1
    
    var timer = Timer()
    var progress_value = 0.1

    //Audio Crop view
    var mergeSlidervw: OptiRangeSliderView!
    
    //Video Crop view
//    var cropSlidervw: OptiRangeSliderView!
    
    //rangeSlider
    var rangeSlider: SlickRangeSlider! = nil
    
    //MARK: IBOutlets
    @IBOutlet weak var collectnvw_Menu: UICollectionView!
    @IBOutlet weak var video_vw: UIView!
    @IBOutlet weak var menu_Vw: UIView!
    @IBOutlet weak var vw_function: UIView!
    @IBOutlet weak var progress_Vw: UIProgressView!
    @IBOutlet weak var scrl_vw: UIScrollView!
    @IBOutlet weak var vw_parent: UIView!
    @IBOutlet weak var progressvw_back: UIView!
    @IBOutlet weak var constraintparantvw_Height: NSLayoutConstraint!
    @IBOutlet weak var constraintvideovw_Height: NSLayoutConstraint!
    @IBOutlet weak var constraintmergemusicvw_height: NSLayoutConstraint!
    @IBOutlet weak var btn_selectVideo: UIButton!
    @IBOutlet weak var vw_selectvideo: UIView!
    
    //Effect View
    @IBOutlet weak var effect_Vw: UIView!
    @IBOutlet weak var effect_CollVw: UICollectionView!
    
    //Speed View
    @IBOutlet weak var speed_Vw: UIView!
    @IBOutlet weak var speed_Collvw: UICollectionView!
    
    //Sticker View
    @IBOutlet weak var sticker_Vw: UIView!
    @IBOutlet weak var sticker_Collvw: UICollectionView!
    @IBOutlet weak var stickerPostion_Collvw: UICollectionView!
    
    //TransitionView
    @IBOutlet weak var transition_Vw: UIView!
    @IBOutlet weak var transition_Collvw: UICollectionView!
    
    //MergeView
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var mergeFirst: UIButton!
    @IBOutlet weak var mergeSecond: UIButton!
    
    //Merge Music View
    @IBOutlet weak var merge_Musicbacvw: UIView!
    @IBOutlet weak var mergeSliderView: UIView!
    @IBOutlet weak var txtAudioLbl: UILabel!
    
    //TextView
    @IBOutlet weak var vw_AddTextView: UIView!
    @IBOutlet weak var txtfld_Addtxt: UITextField!
    @IBOutlet weak var textPosition_Collvw: UICollectionView!
    
    //Video Crop View
    @IBOutlet weak var crop_Vw: UIView!
    @IBOutlet weak var lbl_StartTime: UILabel!
    @IBOutlet weak var lbl_EndTime: UILabel!
    @IBOutlet weak var cropVideoimgFrame_vw: UIView!
    @IBOutlet weak var videoFrames_Vw: UIView!
    
    // Array Declartion
    var menuItems = ["filterW","cropW","audiomergeW","speedW","textW","stickerW", "videomergeW", "transitionW"]
    
    var filterNames = ["Luminance","Chrome","Fade","Instant","Noir","Process","Tonal","Transfer","SepiaTone","ColorClamp","ColorInvert","ColorMonochrome","SpotLight","ColorPosterize","BoxBlur","DiscBlur","GaussianBlur","MaskedVariableBlur","MedianFilter","MotionBlur","NoiseReduction"]
    
    var speedItems = ["0.25", "0.5", "0.75", "1.0", "1.25", "1.5"]
    
    var positionItems = ["BottomLeft","BottomCenter","BottomRight","CenterLeft","Center","CenterRight","TopLeft","TopCenter","TopRight"]
    
    var transitionItems = ["Right to Left","Left to Right","Top to Bottom","Bottom to Top", "Lefttop to Rightbottom","Rightbottom to Lefttop", "Fade in/out"]

    //Mark: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTitle("Marvel Editor", andImage: UIImage(named: "logo")!)
        
        //Collection view Cell NIB Identifier
        collectnvw_Menu.register(UINib(nibName: OptiConstant().CMenuCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CMenuCell)
        effect_CollVw.register(UINib(nibName: OptiConstant().CEffectCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CEffectCell)
        speed_Collvw.register(UINib(nibName: OptiConstant().CSpeedCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CSpeedCell)
        sticker_Collvw.register(UINib(nibName: OptiConstant().CMenuCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CMenuCell)
        transition_Collvw.register(UINib(nibName: OptiConstant().CSpeedCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CSpeedCell)
        stickerPostion_Collvw.register(UINib(nibName: OptiConstant().CSpeedCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CSpeedCell)
        textPosition_Collvw.register(UINib(nibName: OptiConstant().CSpeedCell, bundle: Bundle.main), forCellWithReuseIdentifier: OptiConstant().CSpeedCell)
        
        self.mergeView.isHidden = true
        self.effect_Vw.isHidden = true
        self.speed_Vw.isHidden = true
        self.sticker_Vw.isHidden = true
        self.transition_Vw.isHidden = true
        self.vw_AddTextView.isHidden = true
        self.merge_Musicbacvw.isHidden = true
        self.progressvw_back.isHidden = true
        self.progress_Vw.progress = 0.0
        if self.slctVideoUrl == nil {
            self.btn_selectVideo.isHidden = false
            self.vw_selectvideo.isHidden = true
        }
        self.setupAudioCropSliderView()

        NotificationCenter.default.addObserver(self, selector: #selector(OptiViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OptiViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            if UIDevice.current.orientation.isLandscape {
                self.constraintvideovw_Height = self.constraintvideovw_Height.setMultiplier(multiplier: 0.6)
                self.constraintparantvw_Height = self.constraintparantvw_Height.setMultiplier(multiplier: 1.4)
                self.constraintmergemusicvw_height = self.constraintmergemusicvw_height.setMultiplier(multiplier: 0.72)
                self.scrl_vw.contentSize = CGSize(width: self.view.frame.size.width, height:(self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 20)

            } else {
                self.constraintvideovw_Height = self.constraintvideovw_Height.setMultiplier(multiplier: 0.65)
                self.constraintparantvw_Height = self.constraintparantvw_Height.setMultiplier(multiplier: 1.0)
                self.constraintmergemusicvw_height = self.constraintmergemusicvw_height.setMultiplier(multiplier: 0.65)
                self.scrl_vw.contentSize = CGSize(width: self.view.frame.size.width, height:self.vw_parent.frame.size.height)

            }
            self.collectnvw_Menu.reloadData()
            self.effect_CollVw.reloadData()
            self.speed_Collvw.reloadData()
            self.sticker_Collvw.reloadData()
            self.transition_Collvw.reloadData()
            self.stickerPostion_Collvw.reloadData()
            self.textPosition_Collvw.reloadData()
        }
    }
    
    //MARK : Timer
    func setTimer()  {
        self.progress_value = 0.1
        timer.fire()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(updateProgressValue), userInfo: nil, repeats: true)
    }
    

    func setupAudioCropSliderView()  {
        if self.mergeSlidervw == nil {
            self.mergeSlidervw = OptiRangeSliderView(frame: CGRect(x: 20, y: -15 ,width: self.mergeSliderView.frame.size.width - 40,height: self.mergeSliderView.frame.size.height))
            self.mergeSlidervw.delegate = self
            self.mergeSlidervw.tag = 2
            self.mergeSlidervw.thumbTintColor = UIColor.lightGray
            self.mergeSlidervw.trackHighlightTintColor = UIColor.darkGray
            self.mergeSlidervw.lowerLabel?.textColor = UIColor.lightGray
            self.mergeSlidervw.upperLabel?.textColor = UIColor.lightGray
            self.mergeSlidervw.trackTintColor = UIColor.lightGray
            self.mergeSlidervw.thumbBorderColor = UIColor.clear
            self.mergeSlidervw.lowerValue = 0.0
            self.mergeSlidervw.upperValue = audioTotalsec
            self.mergeSlidervw.stepValue = 5
            self.mergeSlidervw.gapBetweenThumbs = 5
            self.mergeSlidervw.thumbLabelStyle = .FOLLOW
            self.mergeSlidervw.lowerDisplayStringFormat = "%.0f"
            self.mergeSlidervw.upperDisplayStringFormat = "%.0f"
            self.mergeSlidervw.sizeToFit()
            self.mergeSliderView.addSubview(self.mergeSlidervw)
        }
    }
    
    //MARK: Video Play Action
    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        self.avplayer = AVPlayer(url: videoUrl)
        playerController.player = self.avplayer
        self.addChild(playerController)
        view.addSubview(playerController.view)
        playerController.view.frame = view.bounds
        playerController.showsPlaybackControls = true
        self.avplayer.play()
    }
    
    //Create range slider
    func createRangeSlider() {
 
      //  Remove slider if already present
        let subViews = self.cropVideoimgFrame_vw.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        rangeSlider =  SlickRangeSlider(frame: CGRect(x: 0, y:  10 ,width: self.cropVideoimgFrame_vw.frame.size.width,height: self.cropVideoimgFrame_vw.frame.size.height))//SlickRangeSlider(frame: cropVideoimgFrame_vw.bounds)
        cropVideoimgFrame_vw.addSubview(rangeSlider)
        rangeSlider.tag = 1000

        //Range slider action
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)

        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangeSlider.trackHighlightTintColor = UIColor.clear
            self.rangeSlider.curvaceousness = 1.0
        }
    }
    
    func showCropviewAfterVideoisPicked() {
     
        if let videourl = self.slctVideoUrl {
            self.createImageFramesforCrop(strUrl: videourl)
            self.crop_Vw.isHidden = false
        }
        isSliderEnd = true
        if videoTotalsec < 60 {
            lbl_StartTime.text = "\(0.0)s"
            lbl_EndTime.text   = String(format: "%.2fs",(videoTotalsec))
        }else {
            lbl_StartTime.text = "\(0.0)m"
            lbl_EndTime.text   = String(format: "%.2fm",(videoTotalsec/60))
        }
        self.createRangeSlider()
    }
    
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.avplayer.currentTime().timescale)
        self.avplayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        if(pos == CGFloat(videoTotalsec))
        {
            self.avplayer.pause()
        }
    }
    func galleryViewAction() {
        self.avplayer.pause()
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        videoPickerController.transitioningDelegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
        videoPickerController.allowsEditing = true
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.videoMaximumDuration = TimeInterval(240.0)
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.modalPresentationStyle = .custom
        self.present(videoPickerController, animated: true, completion: nil)
    }
    func cameraViewAction() {
        self.avplayer.pause()
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            DispatchQueue.main.async {
                OptiToast.showNegativeMessage(message: OptiConstant().cameranotavailable)
            }
            return
        }
        videoPickerController.allowsEditing = true
        videoPickerController.sourceType = .camera
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.videoMaximumDuration = TimeInterval(240.0)
        videoPickerController.cameraCaptureMode = .video
        videoPickerController.modalPresentationStyle = .fullScreen
        self.present(videoPickerController, animated: true, completion: nil)
    }
    
    //MARK: Objc method Actions
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        if isMergeClicked == true {
            self.assetArray.removeAll()
            self.isMergeClicked = false
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
            self.vw_function.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func updateProgressValue() {
        DispatchQueue.main.async {
            self.progress_value += 0.05
            if self.progress_value < 0.9 {
                self.progress_Vw.progress = Float(self.progress_value)
            }else{
                self.timer.invalidate()
            }
        }
    }
    //MARK: rangeSlider Delegate
    @objc func rangeSliderValueChanged(_ rangeSlider: OptiRangeSlider) {
        self.avplayer.pause()
        if(isSliderEnd == true)
        {
            if  self.slctVideoUrl != nil {
                rangeSlider.minimumValue = 0.0
                rangeSlider.maximumValue = videoTotalsec
                rangeSlider.upperValue = videoTotalsec
            }
            isSliderEnd = !isSliderEnd
        }
//        print("rangeSlider.lowerValue", rangeSlider.lowerValue)
//        print("rangeSlider.upperValue", rangeSlider.upperValue)
        if rangeSlider.upperValue < 60 {
            self.lbl_StartTime.text = String(format: "%.2fs",(rangeSlider.lowerValue))
            self.lbl_EndTime.text   = String(format: "%.2fs",(rangeSlider.upperValue))
        } else {
            self.lbl_StartTime.text = String(format: "%.2fm",(rangeSlider.lowerValue/60))
            self.lbl_EndTime.text   = String(format: "%.2fm",(rangeSlider.upperValue/60))
        }
        self.cropsliderminimumValue = rangeSlider.lowerValue
        self.cropslidermaximumValue = rangeSlider.upperValue
        if(rangeSlider.lowerLayerSelected)
        {
            self.seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
        }else{
            self.seekVideo(toPos: CGFloat(rangeSlider.upperValue))
        }
    }
    
    @objc func saveActionforEditedVideo() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Video Editor", message: OptiConstant().savevideo, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
                if let videourl = self.slctVideoUrl {
                    let getalbum = UserDefaults.standard.bool(forKey: "AlbumCreated")
                    if getalbum {
                        OptiVideoEditor().save(videoUrl: videourl, toAlbum: "Video Editor", completionHandler: { (saved, error) in
                            DispatchQueue.main.async {
                                if saved {
                                    let saveBarBtnItm = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
                                    self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                    OptiToast.showPositiveMessage(message: OptiConstant().videosaved)
                                }else {
                                    OptiToast.showNegativeMessage(message: error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }else{
                        OptiVideoEditor().createAlbum(withTitle: "Video Editor", completionHandler: { (album) in
                            OptiVideoEditor().save(videoUrl: videourl, toAlbum: "Video Editor", completionHandler: { (saved, error) in
                                DispatchQueue.main.async {
                                    if saved {
                                        let saveBarBtnItm = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
                                        self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                        OptiToast.showPositiveMessage(message: OptiConstant().videosaved)
                                    }else {
                                        OptiToast.showNegativeMessage(message: error?.localizedDescription ?? "")
                                    }
                                }
                            })
                        })
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: UIButton IBActions
    @IBAction func addVideoforMerge(_ sender: UIButton) {
        isloadFirstVideo = sender.tag
        // self.gallerybtn_Action(sender)
        OptiVideoEditor().startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        if sender.tag == 1 {
            
        } else {
            
        }
    }
    
    @IBAction func gallerybtn_Action(_ sender: UIButton) {
        self.galleryViewAction()
    }
    
    @IBAction func camerabtn_Action(_ sender: UIButton) {
        self.cameraViewAction()
    }
    
    @IBAction func functionclosebtn_Action(_ sender: UIButton) {
        let saveBarBtnItm = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem  = saveBarBtnItm
        if isMergeClicked == true {
            self.assetArray.removeAll()
            self.isMergeClicked = false
        }
        txtfld_Addtxt.resignFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
                       animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
        }, completion: nil)
        
    }
    @IBAction func btnAction_SelectVideo(_ sender: UIButton) {
        self.vw_selectvideo.isHidden = false
    }
    @IBAction func btnClose_Action(_ sender: UIButton) {
        self.vw_selectvideo.isHidden = true
    }
    @IBAction func btnAction_SelectVideofrmGallery(_ sender: UIButton) {
        self.galleryViewAction()
    }
    @IBAction func btnAction_RecordVideo(_ sender: UIButton) {
        self.cameraViewAction()
    }
    
    @IBAction func tickbtn_Action(_ sender: UIButton) {
        self.txtfld_Addtxt.resignFirstResponder()
        if isMergeClicked == true {
            self.avplayer.pause()
            if assetArray.count > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                    self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                    self.vw_function.layoutIfNeeded()
                }, completion: nil)
                self.progressvw_back.isHidden = false
                self.progress_Vw.progress = 0.1
                self.setTimer()
                self.isMergeClicked = false
                OptiVideoEditor().mergeTwoVideosArry(arrayVideos: assetArray, success: { (url) in
                    DispatchQueue.main.async {
                        let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                        self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                        self.progress_Vw.progress = 1.0
                        self.slctVideoUrl = url
                        self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                        self.assetArray.removeAll()
                        self.audioAsset = nil
                        self.progressvw_back.isHidden = true
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        OptiToast.showNegativeMessage(message: error ?? "")
                        self.progressvw_back.isHidden = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    OptiToast.showNegativeMessage(message: OptiConstant().select2video)
                }
            }
        } else {
            if effect_Vw.isHidden ==  false {
                self.avplayer.pause()
                if let videourl = slctVideoUrl {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
                    }, completion: nil)
                    if strSelectedEffect.count > 0 {
                        self.progressvw_back.isHidden = false
                        self.progress_Vw.progress = 0.1
                        self.setTimer()
                        OptiVideoEditor().addfiltertoVideo(strfiltername: strSelectedEffect, strUrl: videourl, success: { (url) in
                            DispatchQueue.main.async {
                                let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                                self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                self.progress_Vw.progress = 1.0
                                self.slctVideoUrl = url
                                self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                                self.progressvw_back.isHidden = true
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                OptiToast.showNegativeMessage(message: error ?? "")
                                self.progressvw_back.isHidden = true
                            }
                        }
                    }
                }
                
            } else if speed_Vw.isHidden ==  false {
                self.avplayer.pause()
                if let videourl = slctVideoUrl {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
                    }, completion: nil)
                    if strSelectedSpeed.count > 0 {
                        self.progressvw_back.isHidden = false
                        self.progress_Vw.progress = 0.1
                        self.setTimer()
                        let num = strSelectedSpeed.toDouble()
                        OptiVideoEditor().videoScaleAssetSpeed(fromURL: videourl, by: num ?? 1.0, success: { (url) in
                            DispatchQueue.main.async {
                                let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                                self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                self.progress_Vw.progress = 1.0
                                self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                                self.progressvw_back.isHidden = true
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                OptiToast.showNegativeMessage(message: error ?? "")
                                self.progressvw_back.isHidden = true
                            }
                        }
                    }
                }
            }else if vw_AddTextView.isHidden == false {
                self.avplayer.pause()
                if let videourl = self.slctVideoUrl {
                    if selectedTextPosition != -1 && txtfld_Addtxt.text != "" {
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        self.progressvw_back.isHidden = false
                        self.progress_Vw.progress = 0.1
                        self.setTimer()
                        OptiVideoEditor().addStickerorTexttoVideo(videoUrl: videourl, watermarkText: txtfld_Addtxt.text ?? "", imageName: "", position: selectedTextPosition, success: { (url) in
                            DispatchQueue.main.async {
                                let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                                self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                self.progress_Vw.progress = 1.0
                                self.slctVideoUrl = url
                                self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                                self.progressvw_back.isHidden = true
                            }
                        }){ (error) in
                            DispatchQueue.main.async {
                                OptiToast.showNegativeMessage(message: error ?? "")
                                self.progressvw_back.isHidden = true
                            }
                        }
                    }else if txtfld_Addtxt.text == "" {
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().addtext)
                        }
                    } else if selectedTextPosition == -1 {
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctpositionfrtxt)
                        }
                    }
                    
                }
                
            } else if sticker_Vw.isHidden == false {
                self.avplayer.pause()
                if let videourl = self.slctVideoUrl {
                    if selectedStickerPosition != -1 && strSelectedSticker != "" {
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        self.progressvw_back.isHidden = false
                        self.progress_Vw.progress = 0.1
                        self.setTimer()
                        OptiVideoEditor().addStickerorTexttoVideo(videoUrl: videourl, watermarkText: "", imageName: strSelectedSticker, position: selectedStickerPosition, success: { (url) in
                            DispatchQueue.main.async {
                                let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                                self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                self.progress_Vw.progress = 1.0
                                self.slctVideoUrl = url
                                //  self.cropView.isHidden = true
                                self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                                self.progressvw_back.isHidden = true
                            }
                        }){ (error) in
                            DispatchQueue.main.async {
                                OptiToast.showNegativeMessage(message: error ?? "")
                                self.progressvw_back.isHidden = true
                            }
                        }
                    }else if strSelectedSticker == "" {
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slcttsticker)
                        }
                        
                    } else if selectedStickerPosition == -1  {
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctpositonfrsticker)
                        }
                    }
                    
                }
                
            } else if self.crop_Vw.isHidden == false {
                self.avplayer.pause()
                if let videourl = self.slctVideoUrl {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
                    }, completion: nil)
                    self.progressvw_back.isHidden = false
                    self.progress_Vw.progress = 0.1
                    self.setTimer()
                    OptiVideoEditor().trimVideo(sourceURL: videourl, startTime:cropsliderminimumValue, endTime: cropslidermaximumValue, success: { (url) in
                        DispatchQueue.main.async {
                            let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                            self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                            self.progress_Vw.progress = 1.0
                            self.slctVideoUrl = url
                            let asset = AVAsset(url: url)
                            let duration = asset.duration
                            let durationTime = CMTimeGetSeconds(duration)
                            self.videoTotalsec = durationTime
                            self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                            self.progressvw_back.isHidden = true
                        }
                    }){ (error) in
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: error ?? "")
                            self.progressvw_back.isHidden = true
                        }
                    }
                }
            } else if self.transition_Vw.isHidden == false {
                self.avplayer.pause()
                if let videourl = slctVideoUrl {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
                        
                    }, completion: nil)
                    self.progressvw_back.isHidden = false
                    self.progress_Vw.progress = 0.1
                    self.setTimer()
                    OptiVideoEditor().transitionAnimation(videoUrl: videourl, animation: true, type: selectedTransitionType, playerSize: self.video_vw.frame, success: { (url) in
                        DispatchQueue.main.async {
                            let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                            self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                            self.progress_Vw.progress = 1.0
                            self.slctVideoUrl = url
                            self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                            self.progressvw_back.isHidden = true
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: error ?? "")
                            self.progressvw_back.isHidden = true

                        }
                    }
                }
               
            }
        }
    }
    @IBAction func selectAudioClicked(_ sender: Any) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.audio","public.mp3","public.mpeg-4-audio","public.aifc-audio","public.aiff-audio"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func btnAudioVideoMergeClose_Action(_ sender: UIButton) {
        let saveBarBtnItm = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem  = saveBarBtnItm
        self.merge_Musicbacvw.isHidden = true
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
                       animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
        }, completion: nil)
    }
    @IBAction func btn_AudioVideoMergeSave_Action(_ sender: UIButton) {
        if let audiourl = self.slctAudioUrl {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                self.vw_function.layoutIfNeeded()
            }, completion: nil)
            OptiVideoEditor().trimAudio(sourceURL: audiourl, startTime: mergesliderminimumValue, stopTime: mergeslidermaximumValue, success: { (audioUrl) in
                let asset = AVAsset(url: audioUrl)
                let audiosec = CMTimeGetSeconds(asset.duration)
                if self.videoTotalsec >= audiosec {
                    DispatchQueue.main.async {
                        self.progressvw_back.isHidden = false
                        self.progress_Vw.progress = 0.1
                        self.setTimer()
                        self.merge_Musicbacvw.isHidden = true
                        self.mergeView.isHidden = true
                        if  let videourl = self.slctVideoUrl  {
                            OptiVideoEditor().mergeVideoWithAudio(videoUrl: videourl, audioUrl: audioUrl, success: { (url) in
                                DispatchQueue.main.async {
                                    let saveBarBtnItm = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveActionforEditedVideo))
                                    self.navigationItem.rightBarButtonItem  = saveBarBtnItm
                                    self.progress_Vw.progress = 1.0
                                    self.slctVideoUrl = url
                                    self.addVideoPlayer(videoUrl: url, to: self.video_vw)
                                    self.progressvw_back.isHidden = true
                                }
                            }) { (error) in
                                DispatchQueue.main.async {
                                    OptiToast.showNegativeMessage(message: error ?? "")
                                    self.progressvw_back.isHidden = true
                                }
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        OptiToast.showNegativeMessage(message: OptiConstant().cropaudioduration)
                        self.progressvw_back.isHidden = true
                    }
                }
                
            }) { (error) in
                DispatchQueue.main.async {
                    OptiToast.showNegativeMessage(message: error ?? "")
                    self.progressvw_back.isHidden = true
                }
            }
        }
    }
}

//MARK : UIImagePicker Delegate
extension OptiViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        self.dismiss(animated: true, completion: nil)
        
        if let videourl = videoURL {
            if isMergeClicked == true {
                let thumbImg = OptiVideoEditor().generateThumbnail(path: videourl)
                let asset = AVAsset(url: videourl)
                
                if isloadFirstVideo == 1 {
                    self.assetArray.append(asset)
                    self.mergeFirst.setTitle("", for: .normal)
                    self.mergeFirst.setBackgroundImage(thumbImg, for: .normal)
                } else {
                    self.assetArray.append(asset)
                    self.mergeSecond.setTitle("", for: .normal)
                    self.mergeSecond.setBackgroundImage(thumbImg, for: .normal)
                }
                
            } else {
                self.btn_selectVideo.isHidden = true
                self.vw_selectvideo.isHidden = true
                let asset = AVAsset(url: videourl)
                let duration = asset.duration
                let durationTime = CMTimeGetSeconds(duration)
                self.videoTotalsec = durationTime
                self.slctVideoUrl = videoURL
                self.thumImg = OptiVideoEditor().generateThumbnail(path: videourl)
                self.addVideoPlayer(videoUrl: videourl, to: video_vw)
//                if (durationTime / 60) < 4.0 {
//                    self.slctVideoUrl = videoURL
//                    self.thumImg = OptiVideoEditor().generateThumbnail(path: videourl)
//                    self.addVideoPlayer(videoUrl: videourl, to: video_vw)
//                    self.cropSlidervw.maximumValue = self.videoTotalsec
//                    self.cropSlidervw.upperValue = self.videoTotalsec
//                }else{
//                    DispatchQueue.main.async {
//                        self.showCropviewAfterVideoisPicked()
//                        OptiToast.showNegativeMessage(message: OptiConstant().withinthree)
//                    }
//                }
                
            }
            
        }
    }
}
//MARK : UICollectionview Delegate & Datasource
extension OptiViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return menuItems.count
        case 2:
            return filterNames.count
        case 3:
            return speedItems.count
        case 4:
            return 19
        case 5:
            return transitionItems.count
        case 6:
            return positionItems.count
        case 7:
            return positionItems.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            let cell: CollectionViewMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CMenuCell, for: indexPath) as! CollectionViewMenuCell
            cell.imgvw_Menu.image = UIImage(named:menuItems[indexPath.row])
            return cell
        case 2:
            let cell: EffectCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CEffectCell, for: indexPath) as! EffectCollectionCell
            cell.lbl_effectName.text = filterNames[indexPath.row]
            if let convertImage = thumImg {
                cell.effect_Imgvw.image = OptiVideoEditor().convertImageToBW(filterName: CIFilterNames[indexPath.row], image: convertImage)
            }
            cell.effect_Imgvw.layer.borderWidth = 2
            
            if self.filterSelcted == indexPath.row {
                cell.effect_Imgvw.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.effect_Imgvw.layer.borderColor = UIColor.clear.cgColor
            }
            cell.effect_Imgvw.layer.cornerRadius = 12
            cell.effect_Imgvw.layer.masksToBounds = true
            
            return cell
        case 3:
            let cell: SpeedCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CSpeedCell, for: indexPath) as! SpeedCollectionCell
            cell.lbl_speedsec.text = "\(speedItems[indexPath.row])s"
            if strSelectedSpeed == speedItems[indexPath.row] {
                cell.lbl_speedsec.textColor = UIColor.black
                cell.vw_back.backgroundColor = UIColor.white
                cell.vw_back.cornerRadius = 5.0
            } else {
                cell.lbl_speedsec.textColor = UIColor.white
                cell.vw_back.backgroundColor = UIColor.clear
                cell.vw_back.cornerRadius = 0.0
            }
            return cell
        case 4:
            let cell: CollectionViewMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CMenuCell, for: indexPath) as! CollectionViewMenuCell
            if strSelectedSticker == "sticker\(indexPath.row + 1)" {
                cell.backgroundColor = UIColor.white
                cell.cornerRadius = 5.0
            } else {
                cell.backgroundColor = UIColor.clear
                cell.cornerRadius = 0.0

            }
            cell.imgvw_Menu.image = UIImage(named:"sticker\(indexPath.row + 1)")
            return cell
        case 5:
            let cell: SpeedCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CSpeedCell, for: indexPath) as! SpeedCollectionCell
            cell.lbl_speedsec.text = "\(transitionItems[indexPath.row])"
            if selectedTransitionType == indexPath.row {
                cell.lbl_speedsec.textColor = UIColor.black
                cell.vw_back.backgroundColor = UIColor.white
                cell.vw_back.cornerRadius = 5.0
            } else {
                cell.lbl_speedsec.textColor = UIColor.white
                cell.vw_back.backgroundColor = UIColor.clear
                cell.vw_back.cornerRadius = 0.0
            }
            return cell
        case 6:
            let cell: SpeedCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CSpeedCell, for: indexPath) as! SpeedCollectionCell
            cell.lbl_speedsec.text = "\(positionItems[indexPath.row])"
            if selectedStickerPosition == indexPath.row {
                cell.lbl_speedsec.textColor = UIColor.black
                cell.vw_back.backgroundColor = UIColor.white
                cell.vw_back.cornerRadius = 5.0
            } else {
                cell.lbl_speedsec.textColor = UIColor.white
                cell.vw_back.backgroundColor = UIColor.clear
                cell.vw_back.cornerRadius = 0.0
            }
            return cell
        case 7:
            let cell: SpeedCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: OptiConstant().CSpeedCell, for: indexPath) as! SpeedCollectionCell
            cell.lbl_speedsec.text = "\(positionItems[indexPath.row])"
            if selectedTextPosition == indexPath.row {
                cell.lbl_speedsec.textColor = UIColor.black
                cell.vw_back.backgroundColor = UIColor.white
                cell.vw_back.cornerRadius = 5.0
            } else {
                cell.lbl_speedsec.textColor = UIColor.white
                cell.vw_back.backgroundColor = UIColor.clear
                cell.vw_back.cornerRadius = 0.0
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIApplication.shared.statusBarOrientation
        if(orientation == .landscapeLeft || orientation == .landscapeRight)
        {
            switch collectionView.tag {
            case 1:
                return CGSize(width: collectnvw_Menu.frame.width / 7.0, height: collectnvw_Menu.frame.height - 40)
            case 2:
                return CGSize(width: effect_CollVw.frame.width / 4.0, height: effect_CollVw.frame.height)
            case 3:
                return CGSize(width: speed_Collvw.frame.width / 7.0, height: speed_Collvw.frame.height - 60)
            case 4:
                return CGSize(width: sticker_Collvw.frame.width / 6.0, height: sticker_Collvw.frame.height )
            case 5:
                return CGSize(width: transition_Collvw.frame.width / 5.0, height: transition_Collvw.frame.height - 60)
            case 6:
                return CGSize(width: stickerPostion_Collvw.frame.width / 5.0, height: stickerPostion_Collvw.frame.height)
            case 7:
                return CGSize(width: textPosition_Collvw.frame.width / 5.0, height: textPosition_Collvw.frame.height)
            default:
                return CGSize(width: collectnvw_Menu.frame.width / 7.0, height: collectnvw_Menu.frame.height - 40)
            }
        } else {
            switch collectionView.tag {
            case 1:
                return CGSize(width: collectnvw_Menu.frame.width / 7.0, height: collectnvw_Menu.frame.height - 30)
            case 2:
                return CGSize(width: effect_CollVw.frame.width / 2.8, height: effect_CollVw.frame.height)
            case 3:
                return CGSize(width: speed_Collvw.frame.width / 6.0, height: speed_Collvw.frame.height - 70)
            case 4:
                return CGSize(width: sticker_Collvw.frame.width / 5.0, height: sticker_Collvw.frame.height - 10)
            case 5:
                return CGSize(width: transition_Collvw.frame.width / 2.5, height: transition_Collvw.frame.height - 70)
            case 6:
                return CGSize(width: stickerPostion_Collvw.frame.width / 2.5, height: stickerPostion_Collvw.frame.height)
            case 7:
                return CGSize(width: textPosition_Collvw.frame.width / 2.5, height: textPosition_Collvw.frame.height)
            default:
                return CGSize(width: collectnvw_Menu.frame.width / 7.0, height: collectnvw_Menu.frame.height - 30)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch collectionView.tag {
        case 1:
            return UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        case 2:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        case 3:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        case 4:
            return UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        case 5:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        case 6:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        case 7:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        default:
            return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        }
        
    }
}
extension OptiViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.progressvw_back.isHidden == true {
            switch collectionView.tag {
            case 1:
                switch indexPath.row {
                    
                case 0:
                    // Filter Applied
                    if (self.slctVideoUrl != nil) {
                        self.filterSelcted = 100
                        self.avplayer.pause()
                        self.effect_Vw.isHidden = false
                        self.speed_Vw.isHidden = true
                        self.sticker_Vw.isHidden = true
                        self.mergeView.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = true
                        self.effect_CollVw.reloadData()
                        
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideofilter)
                        }
                    }
                case 1:
                    // crop Video
                    if (self.slctVideoUrl != nil) {
                        self.showCropviewAfterVideoisPicked()
                        self.avplayer.pause()
                        self.mergeView.isHidden = true
                        self.effect_Vw.isHidden = true
                        self.speed_Vw.isHidden = true
                        self.sticker_Vw.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = false
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = true
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideocrop)
                        }
                    }
                case 2:
                    //Audio  merge
                    if (self.slctVideoUrl != nil) {
                        self.avplayer.pause()
                        self.mergeView.isHidden = true
                        self.effect_Vw.isHidden = true
                        self.speed_Vw.isHidden = true
                        self.sticker_Vw.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = false
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y + self.menu_Vw.bounds.height) + 360 , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideomergeaudio)
                        }
                    }
                case 3:
                    // SpeedView
                    if (self.slctVideoUrl != nil) {
                        self.avplayer.pause()
                        self.speed_Vw.isHidden = false
                        self.effect_Vw.isHidden = true
                        self.sticker_Vw.isHidden = true
                        self.mergeView.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = true
                        self.speed_Collvw.reloadData()
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideospeed)
                        }
                    }
                case 4:
                    // addTextView
                    if (self.slctVideoUrl != nil) {
                        self.avplayer.pause()
                        self.sticker_Vw.isHidden = true
                        self.effect_Vw.isHidden = true
                        self.speed_Vw.isHidden = true
                        self.mergeView.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = false
                        self.merge_Musicbacvw.isHidden = true
                        self.textPosition_Collvw.reloadData()
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideoaddtxt)
                        }
                    }
                case 5:
                    // addStickerView
                    if (self.slctVideoUrl != nil) {
                        self.avplayer.pause()
                        self.sticker_Vw.isHidden = false
                        self.effect_Vw.isHidden = true
                        self.speed_Vw.isHidden = true
                        self.mergeView.isHidden = true
                        self.transition_Vw.isHidden = true
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = true
                        self.sticker_Collvw.reloadData()
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    }else{
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideosticker)
                        }
                    }
                case 6:
                    // Merge two Videos
                    //                if (self.slctVideoUrl != nil) {
                    self.avplayer.pause()
                    self.isMergeClicked = true
                    self.sticker_Vw.isHidden = true
                    self.effect_Vw.isHidden = true
                    self.speed_Vw.isHidden = true
                    self.mergeView.isHidden = false
                    self.transition_Vw.isHidden = true
                    self.crop_Vw.isHidden = true
                    self.vw_AddTextView.isHidden = true
                    self.merge_Musicbacvw.isHidden = true
                    self.mergeFirst.setBackgroundImage(UIImage(named: ""), for: .normal)
                    self.mergeSecond.setBackgroundImage(UIImage(named: ""), for: .normal)
                    self.mergeFirst.setTitle("+", for: .normal)
                    self.mergeSecond.setTitle("+", for: .normal)
                    self.mergeSecond.setBackgroundImage(UIImage(named: ""), for: .normal)
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                        self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                        self.vw_function.layoutIfNeeded()
                    }, completion: nil)
                    //                } else {
                    //                    OptiToast.showNegativeMessage(message: OptiConstant().slctvideomerge)
                //                }
                case 7:
                    // addTransitionView
                    if (self.slctVideoUrl != nil) {
                        self.avplayer.pause()
                        self.sticker_Vw.isHidden = true
                        self.effect_Vw.isHidden = true
                        self.speed_Vw.isHidden = true
                        self.mergeView.isHidden = true
                        self.transition_Vw.isHidden = false
                        self.crop_Vw.isHidden = true
                        self.vw_AddTextView.isHidden = true
                        self.merge_Musicbacvw.isHidden = true
                        self.transition_Collvw.reloadData()
                        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
                            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                            self.vw_function.layoutIfNeeded()
                        }, completion: nil)
                        
                    } else {
                        DispatchQueue.main.async {
                            OptiToast.showNegativeMessage(message: OptiConstant().slctvideotransition)
                        }
                    }
                    
                default:
                    break
                }
            case 2:
                //effect view
                if effect_Vw.isHidden == false {
                    self.filterSelcted = indexPath.row
                    self.strSelectedEffect = CIFilterNames[indexPath.row]
                    self.effect_CollVw.reloadData()
                }
            case 3:
                //speed view
                if speed_Vw.isHidden == false {
                    self.strSelectedSpeed = speedItems[indexPath.row]
                    self.speed_Collvw.reloadData()
                }
            case 4:
                //sticker view
                if sticker_Vw.isHidden == false {
                    self.strSelectedSticker = "sticker\(indexPath.row + 1)"
                    self.sticker_Collvw.reloadData()
                }
            case 5:
                //transition view
                if transition_Vw.isHidden == false {
                    self.selectedTransitionType = indexPath.row
                    self.transition_Collvw.reloadData()
                }
            case 6:
                //sticker view
                if sticker_Vw.isHidden == false {
                    self.selectedStickerPosition = indexPath.row
                    self.stickerPostion_Collvw.reloadData()
                }
            case 7:
                //text view
                if vw_AddTextView.isHidden == false {
                    self.selectedTextPosition = indexPath.row
                    self.textPosition_Collvw.reloadData()
                }
            default:
                if effect_Vw.isHidden == false {
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                OptiToast.showNegativeMessage(message: OptiConstant().anotheraction)
            }
        }
    }
}


extension OptiViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true) {
            let selectedSongs = mediaItemCollection.items
            guard let song = selectedSongs.first else { return }
            
            let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
            self.audioAsset = (url == nil) ? nil : AVAsset(url: url!)
            let message = (url == nil) ? "Audio Not Loaded" : "Audio Loaded"
            OptiToast.showNegativeMessage(message: message)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension OptiViewController : OptiRangeSliderViewDelegate {
    
    func sliderValueChanged(slider: OptiRangeSlider?,slidervw : OptiRangeSliderView) {
        switch slidervw.tag {
        case 2:
            mergesliderminimumValue = slider?.lowerValue ?? 0.0
            mergeslidermaximumValue = slider?.upperValue ?? 0.0
        default:
            break
        }
        
    }
}
extension OptiViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
        textField.resignFirstResponder()

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],animations: {
                self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: (self.menu_Vw.frame.origin.y - 200) , width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
                self.vw_function.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],animations: {
            self.vw_function.frame = CGRect(x: self.menu_Vw.frame.origin.x, y: self.menu_Vw.frame.origin.y, width: self.menu_Vw.bounds.width, height: self.menu_Vw.bounds.height)
            self.vw_function.layoutIfNeeded()
        }, completion: nil)
    }
}


extension OptiViewController : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if(urls.count > 0) {
                let asset = AVAsset(url: urls.first!)
                self.audioTotalsec = CMTimeGetSeconds(asset.duration)
                self.pickedFileName =  urls.first!.lastPathComponent
                self.slctAudioUrl = urls.first!
                txtAudioLbl.text = self.pickedFileName
                self.mergeSlidervw.maximumValue = self.audioTotalsec
                self.mergeSlidervw.upperValue = self.audioTotalsec
                self.mergesliderminimumValue = 0.0
                self.mergeslidermaximumValue = self.audioTotalsec
            }
        }
    }
}
extension OptiViewController {
    //MARK: Create video Image Frames
    func createImageFramesforCrop(strUrl : URL) {
        
        //Avsset creation
        let asset = AVAsset(url: strUrl)
        
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.videoFrames_Vw.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.videoFrames_Vw.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch _ as NSError
            {
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            self.videoFrames_Vw.addSubview(imageButton)
        }
        
    }
}
