// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package com.shareclarity.textdetectwidget.text_detection;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;

import com.shareclarity.textdetectwidget.others.GraphicOverlay;

/**
 * Graphic instance for rendering TextBlock position, size, and ID within an associated graphic
 * overlay view.
 */
public class TextGraphic extends GraphicOverlay.Graphic {

  private static final int TEXT_COLOR = Color.argb(255,255,255,255);
  private static final int FRAME_COLOR = Color.argb(0,121,176,10);
  private static final float TEXT_SIZE = 30.0f;
  private static final float STROKE_WIDTH = 4.0f;

  private final Paint rectPaint;
  private final Paint textPaint;

  private final RectF rectF;
  private final String text;

  TextGraphic(Context context, RectF _rectF, String _text, GraphicOverlay overlay) {
    super(context);

    this.rectF= _rectF;
    this.text= _text;
    this.overlay = overlay;

    rectPaint = new Paint();
    rectPaint.setColor(FRAME_COLOR);
    rectPaint.setStyle(Paint.Style.FILL);

    textPaint = new Paint();
    textPaint.setColor(TEXT_COLOR);
    textPaint.setTextSize(TEXT_SIZE);
    textPaint.setStrokeWidth(2);
    textPaint.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));

    // Redraw the overlay, as this graphic has been added.
    postInvalidate();
  }

  @Override
  protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    if (rectF == null) {
      throw new IllegalStateException("Attempting to draw a null text.");
    }
    // Draws the bounding box around the TextBlock.
    RectF rect = rectF;
    rect.left = translateX(rect.left);
    rect.top = translateY(rect.top);
    rect.right = translateX(rect.right);
    rect.bottom = translateY(rect.bottom);

    RectF newRect = new RectF();
    newRect.left = rect.width() / 2 + rect.left - 100;
    newRect.top = rect.top;
    newRect.right = rect.width() / 2 + rect.left + 100;
    newRect.bottom = rect.bottom;
//    canvas.drawRect(newRect, rectPaint);
    // Renders the text at the bottom of the box.
    canvas.drawText(text, rect.width() / 2 + rect.left - 60, rect.bottom - 10, textPaint);
  }

  /** Draws the text block annotations for position, size, and raw value on the supplied canvas. */

}
