/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.PropertyReference;
   import PBLabs.Engine.Core.ProcessManager;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Math.Utility;
   
   import flash.display.*;
   import flash.geom.Matrix;
   import flash.geom.Point;

   /**
    * Simple render component that draws an image from a sprite sheet.
    */
   public class SpriteRenderComponent extends BaseRenderComponent
   {
      /**
       * The sprite sheet to use to draw this sprite.
       */
      public function get SpriteSheet():SpriteSheetComponent
      {
         return _spriteSheet;
      }
      
      /**
       * @private
       */
      public function set SpriteSheet(value:SpriteSheetComponent):void
      {
         _spriteSheet = value;
         _spriteDirty = true;
      }
      
      /**
       * The index in the sprite sheet of the frame to draw.
       */
      public function get SpriteIndex():int
      {
         return _spriteIndex;
      }
      
      public function get RawSprite():DisplayObject
      {
         return _sprite;
      }
      
      /**
       * @private
       */
      public function set SpriteIndex(value:int):void
      {
         _spriteIndex = value;
         _spriteDirty = true;
      }
      
      [EditorData(defaultValue="true")]
      public function get Smoothing():Boolean
      {
         return _smoothing;
      }
      
      public function set Smoothing(value:Boolean):void
      {
         _smoothing = value;
         _spriteDirty = true;
      }
      /**
       * Whether or not to flip the sprite about the x axis.
       */
      public function get FlipX():Boolean
      {
         return _flipX;
      }
      
      /**
       * @private
       */
      public function set FlipX(value:Boolean):void
      {
         _flipX = value;
         _spriteDirty = true;
      }
      
      /**
       * Whether or not to flip the sprite about the y axis.
       */
      public function get FlipY():Boolean
      {
         return _flipY;
      }
      
      /**
       * @private
       */
      public function set FlipY(value:Boolean):void
      {
         _flipY = value;
         _spriteDirty = true;
      }
      
      /**
       * Modulate alpha. Zero is fully translucent, one is fully opaque.
       */
      [EditorData(defaultValue="1.0")]
      public var Fade:Number = 1.0;
      
      /**
       * @inheritDoc
       */
      public override function OnDraw(manager:IDrawManager2D):void
      {
         // create the sprite data - this only does anything if necessary
         _GenerateSprite();
         
         // if things aren't loaded yet, the sprite may still be dirty.
         if (_spriteDirty)
            return;
            
         // Skip drawing if it's so invisible as to be unnoticeable.
         if(Fade < 1.0/256.0)
           return;
              
         var position:Point = RenderPosition;
         position = manager.TransformWorldToScreen(position);
         
         var rotation:Number = Owner.GetProperty(RotationReference);
         
         var scale:Point = new Point(1,1);
         var size:Point = Owner.GetProperty(SizeReference);
         if (size)
         {
            scale.x = size.x / _baseSize.x;
            scale.y = size.y / _baseSize.y;
         }
         
         if (_flipX)
            scale.x = -_sprite.scaleX;
         
         if (_flipY)
            scale.y = -_sprite.scaleY;
         
         _sprite.alpha = Fade;         
          
         _matrix.identity();
         _matrix.scale(scale.x,scale.y);
         if(_spriteSheet)
            _matrix.translate(position.x - _spriteSheet.Center.x * scale.x, position.y - _spriteSheet.Center.y * scale.y);
         else
            _matrix.translate(position.x, position.y);
         _matrix.rotate(Utility.GetRadiansFromDegrees(rotation));
         _sprite.transform.matrix = _matrix;  
   
         manager.DrawDisplayObject(_sprite);
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnAdd():void
      {
         _spriteDirty = true;
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnRemove():void 
      {
         _sprite = null;
      }
      
      protected function GetCurrentFrame():BitmapData
      {
         return _spriteSheet.GetFrame(_spriteIndex);
      }
      
      /**
       * Update the cached sprite that we use for rendering.
       */
      protected function _GenerateSprite():void
      {
         // Don't regenerate if we don't need it.
         if (!_spriteDirty)
            return;
         
         if (_spriteSheet == null || !_spriteSheet.IsLoaded)
         {
            // Draw a simple circle.
            _baseSize = new Point(25,25);
            
            if(_sprite == null || !(_sprite is Sprite))
               _sprite = new Sprite();

            (_sprite as Sprite).graphics.clear();
            (_sprite as Sprite).graphics.beginFill(0xFF00FF, 0.5);
            (_sprite as Sprite).graphics.drawCircle(12.5, 12.5, 25);
            (_sprite as Sprite).graphics.endFill();
         }
         else
         {
            var bmpData:BitmapData = GetCurrentFrame();
            if(!bmpData)
            {
               Logger.PrintError(this, "_GenerateSprite", "Failed to get a valid BitmapData back from GetCurrentFrame!");
               _sprite = null;
               return;
            }
            
            _baseSize = new Point(bmpData.width, bmpData.height);
            
            if(_sprite == null || !(_sprite is Bitmap))
              _sprite = new Bitmap(bmpData, "auto", _smoothing);
            else
            {
              (_sprite as Bitmap).bitmapData = bmpData;
              (_sprite as Bitmap).smoothing = _smoothing;
            }
          }
          _spriteDirty = false;
      }
      
      protected var _spriteSheet:SpriteSheetComponent = null;
      protected var _spriteIndex:int = 0;
      protected var _sprite:DisplayObject = null;
      protected var _spriteDirty:Boolean = false;
      protected var _matrix:Matrix = new Matrix();
      protected var _smoothing:Boolean = true;
      
      protected var _baseSize:Point = null;
      protected var _flipX:Boolean = false;
      protected var _flipY:Boolean = false;
   }
}
