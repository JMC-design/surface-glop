(in-package :asdf-user)
(defsystem "surface-glop"
  :description "Surface protocol implementation for GLOP"
  :version "0.0.1"
  :licence "LGPL"
  :author "Johannes Martinez Calzada"
  :depends-on ("surface" "glop" "cl-opengl")
  :components ((:file "package")
               (:file "protocol")
               (:file "documentation")))
