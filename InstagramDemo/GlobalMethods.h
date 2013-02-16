//
//  GlobalMethods.h
//  FindMyPet
//
//  Created by DearDhruv on 02/07/12.
//  Copyright (c) 2012 HB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalMethods : NSObject

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
+(UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
