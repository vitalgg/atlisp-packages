;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 这是使用开发工具 dev-tools 自动创建的程序源文件 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 定义配置项 'qrencode:first 用于 应用包 qrencode 的 第一个配置项 first 
(@:define-config 'qrencode:scale 100 "二维码绘制比例。")
;; (@:get-config 'qrencode:first) ;; 获取配置顶的值
;; (@:set-config 'qrencode:first  "新设的值") ;; 设置配置顶的值
;; 向系统中添加菜单 
(@:add-menu "文本" "生成二维码" "(qrencode:draw)" )
(defun qrencode:hello ()
  (@:help (strcat "这里的内容用于在运行这个功能开始时，对用户进行功能提示。\n"
		  "如怎么使用，注意事项等。\n当用户设置了学习模式时，会在命令行或弹窗进行提示。\n"
		  ))
  ;; 以下部分为你为实现某一功能所编写的代码。
  (princ)
  )
(if (null (findfile (strcat @:*prefix* "bin\\QRencodeForLisp.exe")))
    (@:down-file "bin/QRencodeForLisp.exe"))
(defun qrencode:draw ()
  (@:help "选择文字生成QR二维码")
  (if (setq str (text:get-mtext (car (entsel "请选择一个文本:"))))
      (progn
	(setq str (text:remove-fmt str))
	(qrencode:make str)
	)
    (princ "not select text"))
  (princ)
  )
(defun qrencode:mkpline(pt col)
  (entmake (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") '(100 . "AcDbPolyline") (cons 420 col) (cons 90 2) (cons 10 pt) (cons 10 (polar pt 0 1))(cons 43 1)))
  )
(defun qrencode:make(str / wscript stdout wsreturn outstr pt n k lst ptbase)
  (if (null (findfile (strcat @:*prefix* "bin\\QRencodeForLisp.exe")))
      (progn
	(@:down-file "bin/QRencodeForLisp.exe")
	(alert "正在下载 QRencode ,请稍候...")
	(sleep 10)
	))
  (setq WScript (vlax-get-or-create-object "WScript.Shell"))
  (setq WSreturn (vlax-invoke WScript 'exec (strcat "\"" @:*prefix* "bin\\QRencodeForLisp.exe\" \"" str "\"")))
  (setq stdout (vlax-get WSreturn 'StdOut))
  (setq outstr (vlax-invoke stdout 'Readall))
  (setq lst(read outstr))
  (if lst
      (progn
	(setq ptbase (getpoint "请输入二维码绘制位置:"))
	(foreach n lst
		 (setq pt ptbase)
		 (foreach k n          
			  (if (= k 1) (qrencode:mkpline pt 0) (qrencode:mkpline pt 16777215))
			  (setq pt(polar pt 0 1))
			  )        
		 (setq ptbase(polar ptbase (* pi 1.5) 1))
		 )
	)
    )
  (princ)
  )
