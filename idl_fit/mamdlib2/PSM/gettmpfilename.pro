; Copyright 2007 Observatoire de Paris

; This file is part of the Planck Sky Model.
;
; The Planck Sky Model is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; version 2 of the License.
;
; The Planck Sky Model is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY, without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with the Planck Sky Model. If not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

;+
; return 'number' random filenames prefixed by prefix and suffixed by suffix
;
; @history <p>Marc Betoule, june 2007 : first version</p>
; @history <p>Marc Betoule, june 2007 : add number keyword</p>
; @history <p>Marc Betoule, december 2007 : use getenv('IDL_TMPDIR')</p>
;-
function gettmpfilename, prefix, suffix=suffix, number=number
if not keyword_set(number) then number = 1
if n_params() eq 0 then prefix = 'psm-tmp_'
if not keyword_set(suffix) then suffix = '.fits'
;defsysv, '!psm_scratch', exists=scratch

;if scratch then prefix = fix_separator(!psm_scratch) + prefix
prefix = fix_separator(getenv('IDL_TMPDIR')) + prefix
filename = prefix+strtrim(round(1e7*randomu(noseed,number)),2)+suffix

return, filename

end
