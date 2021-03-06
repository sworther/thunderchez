

(define errors '(
		 ;;FROM linux's asm/errno-base.h
		 EPERM ENOENT ESRCH EINTR EIO ENXIO E2BIG ENOEXEC EBADF ECHILD EAGAIN
		 ENOMEM EACCES EFAULT ENOTBLK EBUSY EEXIST EXDEV ENODEV ENOTDIR EISDIR
		 EINVAL ENFILE EMFILE ENOTTY ETXTBSY EFBIG ENOSPC ESPIPE EROFS EMLINK
		 EPIPE EDOM ERANGE
		 
		 ;;FROM linux's asm/errno.h
		 EDEADLK ENAMETOOLONG ENOLCK

		 ENOSYS

		 ENOTEMPTY ELOOP EWOULDBLOCK ENOMSG EIDRM ECHRNG EL2NSYNC EL3HLT EL3RST
		 ELNRNG EUNATCH ENOCSI EL2HLT EBADE EBADR EXFULL ENOANO EBADRQC EBADSLT

		 EDEADLOCK

		 EBFONT ENOSTR ENODATA ETIME ENOSR ENONET ENOPKG EREMOTE ENOLINK EADV
		 ESRMNT ECOMM EPROTO EMULTIHOP EDOTDOT EBADMSG EOVERFLOW ENOTUNIQ
		 EBADFD EREMCHG ELIBACC ELIBBAD ELIBSCN ELIBMAX ELIBEXEC EILSEQ
		 ERESTART ESTRPIPE EUSERS ENOTSOCK EDESTADDRREQ EMSGSIZE EPROTOTYPE
		 ENOPROTOOPT EPROTONOSUPPORT ESOCKTNOSUPPORT EOPNOTSUPP EPFNOSUPPORT
		 EAFNOSUPPORT EADDRINUSE EADDRNOTAVAIL ENETDOWN ENETUNREACH ENETRESET
		 ECONNABORTED ECONNRESET ENOBUFS EISCONN ENOTCONN ESHUTDOWN
		 ETOOMANYREFS ETIMEDOUT ECONNREFUSED EHOSTDOWN EHOSTUNREACH EALREADY
		 EINPROGRESS ESTALE EUCLEAN ENOTNAM ENAVAIL EISNAM EREMOTEIO EDQUOT
		 ENOMEDIUM EMEDIUMTYPE ECANCELED ENOKEY EKEYEXPIRED EKEYREVOKED
		 EKEYREJECTED EOWNERDEAD ENOTRECOVERABLE))

(define (gen-errno platform)
  (call-with-output-file (string-append "errno-" platform ".ss")
    (lambda (p)
      (fprintf p";; generated by errno-c-eval.ss - platform: ~a\n" (machine-type))

      (for-each (lambda (err)
		  (printf "eval'ing ~a...\n" err)
	    (guard (e [else (fprintf p "(define ~a '~a-UNDEFINED)\n" err err)])
		   (fprintf p "(define ~a ~a)\n" err (c-eval-printf "%d" err))))
		errors))
    'truncate))

(c-eval-includes '("stdio.h" "errno.h"))

(cond
 [(memq (machine-type) '(a6le ta6le))
  (gen-errno "linux")]
 [else
  (error 'errno-c-eval.ss "unsupported machine-type ~a" (machine-type))])
