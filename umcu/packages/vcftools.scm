;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2015 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2016 Roel Janssen <roel@gnu.org>
;;;
;;; This file is not officially part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

;; WARNING: This is non-free software. It will NEVER and SHOULD NEVER be
;; mainlined in GNU Guix.  You should avoid using this package, and if you
;; can, please write a free replacement for it.

(define-module (umcu packages vcftools)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config))

(define-public vcftools-0.1.14
  (package
    (name "vcftools")
    (version "0.1.14")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/vcftools/vcftools/archive/v"
                     version ".tar.gz"))
              (sha256
               (base32
                "1pvgv9vzlgny5h3ljcy7fl2iyn98v366kdxnxv0h36aycj20ai5s"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f ; no "check" target
       #:make-flags (list
                     "CFLAGS=-O2" ; override "-m64" flag
                     (string-append "PREFIX=" (assoc-ref %outputs "out"))
                     (string-append "MANDIR=" (assoc-ref %outputs "out")
                                    "/share/man/man1"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'configure 'patch-manpage-install
           (lambda _
             (substitute* "Makefile"
               (("cp \\$\\{PREFIX\\}/cpp/vcftools.1") "cp ./cpp/vcftools.1"))))
         (add-before 'configure 'run-autogen
           (lambda _
             (zero? (system* "sh" "autogen.sh")))))))
    (native-inputs
     `(("autoconf" ,(autoconf-wrapper))
       ("automake" ,automake)
       ("libtool" ,libtool)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("perl" ,perl)
       ("zlib" ,zlib)))
    (home-page "http://vcftools.sourceforge.net/")
    (synopsis "Tools for working with VCF files")
    (description
     "VCFtools is a program package designed for working with VCF files, such
as those generated by the 1000 Genomes Project.  The aim of VCFtools is to
provide easily accessible methods for working with complex genetic variation
data in the form of VCF files.")
    ;; The license is declared as LGPLv3 in the README and
    ;; at http://vcftools.sourceforge.net/license.html
    (license license:lgpl3)))
