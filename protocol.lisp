(in-package #:surface-glop)

(defmethod glop:on-resize ((window glop:window) width height) ;this seems wrong with more than 1 window.
  (surface:resize window (cons width height)))

(defmethod surface:%create ((type (eql :glop)) width height &key (title "replace me") (depth 24) (red 8) (blue 8) (green 8) (alpha 8) (location (cons 0 0)) (resizable t) (visible t) decorated (accum-red 8) (accum-blue 8) (accum-green 8) (accum-alpha 8) (stencil 8) (aux 0) (samples 0) (refresh 60) stereo srgb)
  (glop:create-window title width height :x (car location) :y (cdr location)))

(defmethod surface:prepare         ((surface glop:window) &key (matrix-mode :projection) (ortho '(-1000 1000 -1000 1000 -1000 1000)))
  (glop:attach-gl-context surface (glop:window-gl-context surface))
  (destructuring-bind (x . y) (surface:location surface)
    (destructuring-bind (width . height) (surface:size surface)
      (gl:viewport x y width height)))
  (gl:matrix-mode matrix-mode)
  (gl:load-identity)
  (apply #'gl:ortho ortho)
  (surface:update surface)
  surface)

(defmethod surface:destroy         ((surface glop:window))
  (glop:destroy-window surface))
(defmethod surface:destroy         ((ctx glop::glx-context))
  (glop:destroy-gl-context ctx))

(defmethod surface:update          ((surface glop:window))
  (gl:flush)
  (glop:swap-buffers surface))

(defmethod surface:map             ((surface glop:window))
  (glop:show-window surface))
(defmethod surface:unmap           ((surface glop:window))
  (glop:hide-window surface))
(defmethod surface:visible?        ((surface glop:window))) ;add to glop?

(defmethod surface:size            ((surface glop:window))
  (cons (glop:window-width surface) (glop:window-height surface)))
(defmethod surface:resize          ((surface glop:window) size) ;problem this doesn't get called by wm because it only sees the x11 window over the wire.
  (destructuring-bind (width . height) size
    (glop:set-geometry surface (glop:window-x surface) (glop:window-y surface)width height)
    (gl:viewport 0 0 width height)
    (surface:update surface)))

(defmethod surface:location        ((surface glop:window))
  (cons (glop:window-x surface) (glop:window-y surface)))
(defmethod surface:move            ((surface glop:window) location)
  (glop:set-geometry surface (car location) (cdr location) (glop:window-width surface) (glop:window-height surface)))

(defmethod surface:properties      ((surface glop:window)) ;make this crap meaningful
  (let ((*package* (find-package :glop))) 
    (with-slots ((x glop::x) (y glop::y) (width glop::width) (height glop::height) (title glop::title) (gl-context glop::gl-context) (id glop::id) (visual-infos glop::visual-infos) (fb-config glop::fb-config) (cursor glop::cursor)) surface
      (list x y width height title gl-context id visual-infos fb-config cursor))))

;(defmethod surface:depth           ((surface glop:window))) ;read from visual-infos
;(defmethod surface:bpc             ((surface glop:window)));remove? add to properties?
;(defmethod surface:bpp             ((surface glop:window)));remove? add to properties?

(defmethod surface:buffer          ((surface glop:window)&key name)); while used to get back or front buffers from 2d surfaces, maybe allow get/setting gl buffers? outside scope of protocol?

(defmethod surface:data            ((surface glop:window) &key &allow-other-keys)
  (destructuring-bind (width . height) (surface:size surface)
    (surface:region 0 0 width height surface)))
(defmethod surface:region          (start-x start-y width height (surface glop:window) &optional (format :rgba) (type :unsigned-byte))
  (declare (ignore format))
  (gl:read-pixels start-x (- (glop:window-height surface) start-y) width height format type))


(defmethod surface:clear           ((surface glop:window) &optional colour-array)
  (if colour-array
      (apply #'gl:clear-color (coerce colour-array 'list))
      (gl:clear-color 0 0 0 0))
  (gl:clear :color-buffer-bit)
  (surface:update surface))

(defmethod surface:pixel           (x y (surface glop:window))
  (gl:read-pixels x (- (glop:window-height surface) y) 1 1 :rgba :unsigned-byte))

(defmethod surface:set-pixel       (x y ink (surface glop:window))
  (gl:raster-pos x (- (glop:window-height surface) y))
  (gl:draw-pixels 1 1 :rgba :unsigned-byte ink))

(defmethod surface:attach ((context glop::glx-context) (surface glop:window))
  (glop:attach-gl-context surface context))
(defmethod surface:detach ((surface glop:window))
  (let ((ctx (glop:window-gl-context surface)))
    (glop:detach-gl-context ctx)
    ctx))

;; (defmethod surface:blit            (source (surface glop:window) &optional (src-x 0) (src-y 0) (dest-x 0) (dest-y 0) src-width src-height (format :rgba) (type :unsigned-byte))
;;   (declare (ignorable  src-x src-y dest-x dest-y src-width src-height))
;;   (gl:raster-pos dest-x dest-y)
;;   (gl:draw-pixels src-width src-height format type source))   ;;figure out an appropriate lambda list, might have to take out all optionals.




