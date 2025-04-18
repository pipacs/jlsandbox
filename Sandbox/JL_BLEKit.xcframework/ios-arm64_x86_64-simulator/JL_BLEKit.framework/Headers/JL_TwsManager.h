//
//  JL_TwsManager.h
//  JL_BLEKit
//
//  Created by 凌煊峰 on 2021/12/17.
//  Modify by EzioChan on 2023/08/18
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_FunctionBaseManager.h>
#import <JL_BLEKit/JL_Tools.h>
#import <JL_BLEKit/JLModel_ANC.h>
#import <JL_BLEKit/JLTwsSupportFuncs.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: - 耳机电量
/// 耳机电量
/// TWS earphones Electricity
@interface TwsElectricity:NSObject
/// 左耳充电中
@property(nonatomic,assign) BOOL isChargingLeft;

/// 右耳充电中
@property(nonatomic,assign) BOOL isChargingRight;

/// 充电仓正在充电中
@property(nonatomic,assign) BOOL isChargingCenter;

/// 左耳电量
@property(nonatomic,assign) int powerLeft;

/// 右耳电量
@property(nonatomic,assign) int powerRight;

/// 充电舱电量
@property(nonatomic,assign) int powerCenter;

@end



//MARK: - TWS 控制类
/// TWS 管理者
@interface JL_TwsManager : JL_FunctionBaseManager

/// 扩展功能支持
@property(nonatomic,strong,readonly)JLTwsSupportFuncs *supports;

///耳机电量
///TWS earphones Electricity
@property (nonatomic,strong)TwsElectricity *electricity;

/// 设备名称
@property (nonatomic,strong)NSString *edrName;

/// 按键功能设置
@property (nonatomic,strong)NSArray *keySettings;

/// 灯光场景类型
@property (nonatomic,assign)int ledScen;

/// 灯光效果类型
@property (nonatomic,assign)int ledEffect;

/// 设备麦克风channel
/// 若为空或者0则视为此功能不支持
/// 1：自动切换
/// 2：始终左耳
/// 3：始终右耳
@property (nonatomic,assign)int micMode;

/// 工作模式
/// 若为空或者0则视为此功能不支持
/// 1：普通模式
/// 2：游戏模式
@property (nonatomic,assign)int workMode;

/// 供应商ID
@property (nonatomic,assign)uint16_t vid;

/// 厂商ID
@property (nonatomic,assign)uint16_t uid;

/// 产品ID
@property (nonatomic,assign)uint16_t pid;

/// 连接时长
@property (nonatomic,assign)uint32_t linkTime;

/// 入耳检测
/// 0 -- 不支持此功能
/// 1 -- 关闭
/// 2 -- 打开
@property (nonatomic,assign)uint8_t earEntryDection;

/// 设备语言类型
/// zh -- 中文
/// en -- 英文
@property (nonatomic,strong)NSString *deviceLanguage;

///ANC的模式数组
@property (nonatomic,strong)NSArray *ancModels;

/// HeadSetInfoDict
/// 耳机信息字典
/// 当app端收到设备返回的信息时会更新此值
/// 此值变化较大不适合作为唯一判断依据，容易发生部分值获取失败的问题
@property (nonatomic,strong)NSDictionary *_Nullable headSetInfoDict;


/// 一拖二开关状态
@property(nonatomic,readonly,assign)BOOL dragWithMore;


/**
 @param name 设置对耳设备的EDR名字
 */
-(void)cmdHeadsetEdrName:(NSData*)name;

#pragma mark ---> 按键设置(对耳)
typedef NS_ENUM(UInt8, JL_HeadsetButtonSettingKey) {
    JL_HeadsetButtonSettingKeyOnlyLeftEar      = 0x01,     //左耳
    JL_HeadsetButtonSettingKeyOnlyRightEar     = 0x02,     //右耳
};
typedef NS_ENUM(UInt8, JL_HeadsetButtonSettingAction) {
    JL_HeadsetButtonSettingActionClick            = 0x01,     //单击
    JL_HeadsetButtonSettingActionDoubleClick      = 0x02,     //双击
};
typedef NS_ENUM(UInt8, JL_HeadsetButtonSettingFunction) {
    JL_HeadsetButtonSettingFunctionNone            = 0x00,     //无作用
    JL_HeadsetButtonSettingFunctionBoot            = 0x01,     //开机
    JL_HeadsetButtonSettingFunctionTurnOff         = 0x02,     //关机
    JL_HeadsetButtonSettingFunctionPlayPrevious    = 0x03,     //上一曲
    JL_HeadsetButtonSettingFunctionPlayNext        = 0x04,     //下一曲
    JL_HeadsetButtonSettingFunctionPlayOrPause     = 0x05,     //播放/暂停
    JL_HeadsetButtonSettingFunctionAnswerOrHangup  = 0x06,     //接听/挂断
    JL_HeadsetButtonSettingFunctionReject          = 0x07,     //拒听
    JL_HeadsetButtonSettingFunctionTakePhoto       = 0x08,     //拍照
};
/**
 @param key 左耳0x01 右耳0x02
 @param act 单击0x01 双击0x02
 @param fuc 0x00    无作用
            0x01    开机
            0x02    关机
            0x03    上一曲
            0x04    下一曲
            0x05    播放/暂停
            0x06    接听/挂断
            0x07    拒听
            0x08    拍照
 */
-(void)cmdHeadsetKeySettingKey:(JL_HeadsetButtonSettingKey)key
                        Action:(JL_HeadsetButtonSettingAction)act
                      Function:(JL_HeadsetButtonSettingFunction)fuc;

#pragma mark ---> LED设置(对耳)

typedef NS_ENUM(UInt8, JL_HeadsetScene) {
    JL_HeadsetSceneNotPaired                  = 0x01,     //未配对
    JL_HeadsetSceneDisConnected               = 0x02,     //未连接
    JL_HeadsetSceneConnected                  = 0x03,     //已连接
    JL_HeadsetScenePlayDeviceMusic            = 0x04,     //播放设备音乐
    JL_HeadsetScenePauseDeviceMusic           = 0x05,     //暂停设备音乐
    JL_HeadsetScenePlayExternalAudioSource    = 0x06,     //外部音源播放
    JL_HeadsetScenePauseExternalAudioSource   = 0x07,     //外部音源暂停
};
typedef NS_ENUM(UInt8, JL_HeadsetLedEffect) {
    JL_HeadsetLedEffectAllClose                  = 0x00,     //全灭
    JL_HeadsetLedEffectRedLightOn                = 0x01,     //红灯常亮
    JL_HeadsetLedEffectBlueLightOn               = 0x02,     //蓝灯常亮
    JL_HeadsetLedEffectRedLightBreathing         = 0x03,     //红灯呼吸
    JL_HeadsetLedEffectBlueLightBreathing        = 0x04,     //蓝灯呼吸
    JL_HeadsetLedEffectRedBlueLightQuickFlash    = 0x05,     //红蓝交替快闪
    JL_HeadsetLedEffectRedBlueLightSlowFlash     = 0x06,     //红蓝交替慢闪
};
/**
 @param scene  0x01   未配对
              0x02    未连接
              0x03    连接
              0x04:   播放设备音乐
              0x05：暂停设备音乐
              0x06：外部音源播放
              0x07：外部音源暂停
 @param effect  0x00    全灭
               0x01    红灯常亮
               0x02    蓝灯常亮
               0x03    红灯呼吸
               0x04    蓝灯呼吸
               0x05    红蓝交替快闪
               0x06    红蓝交替慢闪
 */
-(void)cmdHeadsetLedSettingScene:(JL_HeadsetScene)scene
                          Effect:(JL_HeadsetLedEffect)effect;

#pragma mark ---> MIC设置(耳机)
typedef NS_ENUM(UInt8, JL_HeadsetMicSettingMode) {
    JL_HeadsetMicSettingModeOnlyLeftEar      = 0x00,     //仅左耳
    JL_HeadsetMicSettingModeOnlyRightEar     = 0x01,     //仅右耳
    JL_HeadsetMicSettingModeAutomatic        = 0x02,     //自动选择
};
/**
 @param mode JL_HeadsetMicSettingMode
 */
-(void)cmdHeadsetMicSettingMode:(JL_HeadsetMicSettingMode)mode
                         Result:(JL_CMD_RESPOND __nullable)result;

#pragma mark ---> 工作模式(耳机)
typedef NS_ENUM(UInt8, JL_HeadsetWorkingMode) {
    JL_HeadsetWorkingModeNormal      = 0x01,     //普通模式
    JL_HeadsetWorkingModeGame        = 0x02,     //游戏模式
};
/**
 @param mode 1： 普通模式
        2： 游戏模式
 */
-(void)cmdHeadsetWorkSettingMode:(JL_HeadsetWorkingMode)mode;

#pragma mark ---> 同步时间戳(耳机)
/**
 @param date  当前系统时间
*/
-(void)cmdHeadsetTimeSetting:(NSDate*)date;

#pragma mark ---> 获取设备信息(耳机)
typedef void(^JL_HEADSET_BK)(NSDictionary* __nullable dict);
typedef NS_ENUM(uint32_t, JL_HeadsetAdviceFlag) {
    JL_HeadsetAdviceFlagGetElectricity              = 1,            //小机电量获取
    JL_HeadsetAdviceFlagEdrName                     = 1 << 1,       //Edr名称
    JL_HeadsetAdviceFlagButtonFunction              = 1 << 2,       //按键功能
    JL_HeadsetAdviceFlagLedStatus                   = 1 << 3,       //LED显示状态
    JL_HeadsetAdviceFlagMicMode                     = 1 << 4,       //MIC模式
    JL_HeadsetAdviceFlagWorkMode                    = 1 << 5,       //工作模式
    JL_HeadsetAdviceFlagProductInfo                 = 1 << 6,       //产品信息
    JL_HeadsetAdviceFlagConnectingTime              = 1 << 7,       //连接时间
    JL_HeadsetAdviceFlagEarDetection                = 1 << 8,       //入耳检测
    JL_HeadsetAdviceFlagLanguage                    = 1 << 9,       //语言类型
};
/**
 @param flag  BIT0    小机电量获取 格式为3个字节 参考广播包格式
             BIT1    Edr 名称
             BIT2    按键功能
             BIT3    LED 显示状态
             BIT4    MIC 模式
             BIT5    工作模式
             BIT6    产品信息
             BIT7    连接时间
             BIT8    入耳检测
             BIT9    语言类型
 @param result 返回字典：
                @"ISCHARGING_L"
                @"ISCHARGING_R"
                @"ISCHARGING_C"
                @"POWER_L"
                @"POWER_R"
                @"POWER_C"
                @"EDR_NAME"
                @"KEY_LR"
                @"KEY_ACTION"
                @"KEY_FUNCTION"
                @"LED_SCENE"
                @"LED_EFFECT"
                @"MIC_MODE"
                @"WORK_MODE"
                @"VID"
                @"UID"
                @"PID"
                @"LINK_TIME"
                @""IN_EAR_TEST"
                @"DEVICE_LANGUAGE"
                @"KEY_ANC_MODE"    ANC的模式数组
 */
-(void)cmdHeadsetGetAdvFlag:(JL_HeadsetAdviceFlag)flag
                     Result:(JL_HEADSET_BK __nullable)result;

#pragma mark ---> 设备广播通知(耳机)
/**
    @{@"JLID": 杰理ID,
    @"VID": ,
    @"PID":  ,
    @"EDR": ,
    @"SCENE": ,
    @"ISCHARGING_L": ,
    @"ISCHARGING_R": ,
    @"ISCHARGING_C": ,
    @"POWER_L": ,
    @"POWER_R": ,
    @"POWER_C": ,
    @"CHIP_TYPE": ,
    @"PROTOCOL_TYPE": ,
    @"SEQ":};
 */
extern NSString *kJL_MANAGER_HEADSET_ADV;

#pragma mark ---> 设置命令成功/错误回复(耳机)
/**
    0x00：成功
    0x01：游戏模式导致设置失效
    0x02：蓝牙名字长度超出限制
    0x03：非蓝牙模式设置闪灯失败
 */
extern NSString *kJL_MANAGER_HEADSET_SET_ERR;

#pragma mark ---> 关闭或开启设备广播(耳机)
/**
 @param enable 使能位
 */
-(void)cmdHeadsetAdvEnable:(BOOL)enable;

#pragma mark ---> 用于ADV设置同步后需要主机操作的行为。
/**
  1：更新配置信息，需要重启生效。
  2：同步时间戳
  3：请求手机回连BLE
  4：同步设备信息
 */
extern NSString *kJL_MANAGER_HEADSET_TIPS;

#pragma mark ---> 发射频点
/**
@param fmtx  频点
*/
-(void)cmdSetFMTX:(uint16_t)fmtx;

#pragma mark ---> 设置耳机ANC模式列表
/**
 *  设置耳机ANC模式列表
 *  @param array  频点 JL_AncMode的NSNumber对象数组 @[@(JL_AncMode_Normal), @(JL_AncMode_NoiseReduction)]
 */
-(void)cmdHeadsetAncArray:(NSArray*)array;

#pragma mark ---> 耳机主动降噪ANC设置
-(void)cmdSetANC:(JLModel_ANC*)model;



//MARK: - 一拖二相关命令

typedef void(^JL_MulitLinksInfo_BK)(JL_CMDStatus status,NSArray <JLTWSAddrNameInfo *>* __nullable phoneInfos);

/// 设备上传一拖二设备信息列表
extern NSString* kJL_MULIT_NAME_LIST;

/// 获取设备已连接手机名
/// 通知设备上传一拖二设备信息列表
/// @param result 设备所连接的手机名字列表
-(void)cmdGetDeviceInfoListResult:(JL_MulitLinksInfo_BK)result;

/// 通知设备一连上手机地址和绑定信息
/// - Parameters:
///   - addr: 手机EDR地址
///   - name: 手机蓝牙名称
///   - result: 结果
-(void)cmdBindDeviceInfo:(NSData *)addr phone:(NSString *)name result:(JL_MulitLinksInfo_BK)result;

/// 一拖二开关
/// @param dragWithMore 开关状态
/// @param addr 手机的经典蓝牙地址（通过cmdGetDeviceInfoList 获取）
/// @param result   结果回调
-(void)setDragWithMore:(BOOL)dragWithMore phoneBleAddr:(NSData *) addr result:(JL_CMD_RESPOND)result;

@end

NS_ASSUME_NONNULL_END
