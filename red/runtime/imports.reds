Red/System [
	Title:   "Red runtime OS API imported functions definitions"
	Author:  "Nenad Rakocevic"
	File: 	 %imports.reds
	Rights:  "Copyright (C) 2011 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/dockimbel/Red/blob/master/red-system/runtime/BSL-License.txt
	}
]

#define OS-page-size	4096					;@@ target/OS dependent

#either OS = 'Windows [
	#import [
		"kernel32.dll" stdcall [
			OS-VirtualAlloc: "VirtualAlloc" [
				address		[byte-ptr!]
				size		[integer!]
				type		[integer!]
				protection	[integer!]
				return:		[int-ptr!]
			]
			OS-VirtualFree: "VirtualFree" [
				address 	[int-ptr!]
				size		[integer!]
				return:		[integer!]
			]
		]
	]
	
	#define VA_COMMIT_RESERVE	3000h			;-- MEM_COMMIT | MEM_RESERVE
	#define VA_PAGE_RW			04h				;-- PAGE_READWRITE
	#define VA_PAGE_RWX			40h				;-- PAGE_EXECUTE_READWRITE
	
	;-------------------------------------------
	;-- Allocate paged virtual memory region from OS (Windows)
	;-------------------------------------------
	OS-allocate-virtual: func [
		size 	[integer!]						;-- allocated size in bytes (page size multiple)
		exec? 	[logic!]						;-- TRUE => executable region
		return: [int-ptr!]						;-- allocated memory region pointer
		/local ptr prot
	][
		prot: either exec? [VA_PAGE_RWX][VA_PAGE_RW]
		
		ptr: OS-VirtualAlloc 
			null
			size
			VA_COMMIT_RESERVE
			prot
			
		if ptr = null [
			raise-error RED_ERR_VMEM_OUT_OF_MEMORY 0
		]
		ptr
	]
	
	;-------------------------------------------
	;-- Free paged virtual memory region from OS (Windows)
	;-------------------------------------------
	OS-free-virtual: func [
		ptr [int-ptr!]							;-- address of memory region to release
	][
		if negative? OS-VirtualFree ptr ptr/value [
			raise-error RED_ERR_VMEM_RELEASE_FAILED as-integer ptr
		]
	]
][	
	#define MMAP_PROT_RW		03h				;-- PROT_READ | PROT_WRITE
	#define MMAP_PROT_RWX		07h				;-- PROT_READ | PROT_WRITE | PROT_EXEC
	
	#define MMAP_MAP_SHARED     01h
	#define MMAP_MAP_PRIVATE    02h
	#define MMAP_MAP_ANONYMOUS  20h

	#syscall [
		OS-mmap: SYSCALL_MMAP2 [
			address		[byte-ptr!]
			size		[integer!]
			protection	[integer!]
			flags		[integer!]
			fd			[integer!]
			offset		[integer!]
			return:		[byte-ptr!]
		]
		OS-munmap: SYSCALL_MUNMAP [
			address		[byte-ptr!]
			size		[integer!]
			return:		[integer!]
		]
	]
	;-------------------------------------------
	;-- Allocate paged virtual memory region from OS (UNIX)
	;-------------------------------------------
	OS-allocate-virtual: func [
		size 	[integer!]						;-- allocated size in bytes (page size multiple)
		exec? 	[logic!]						;-- TRUE => executable region
		return: [int-ptr!]						;-- allocated memory region pointer
		/local ptr prot
	][
		assert zero? (size and 0Fh)				;-- size is a multiple of 16
		prot: either exec? [MMAP_PROT_RWX][MMAP_PROT_RW]
		
		ptr: OS-mmap 
			null 
			size
			prot	
			MMAP_MAP_PRIVATE or MMAP_MAP_ANONYMOUS
			-1									;-- portable value
			0
			
		if negative? as-integer ptr [
			raise-error RED_ERR_VMEM_OUT_OF_MEMORY as-integer system/pc
		]
		as int-ptr! ptr
	]
	
	;-------------------------------------------
	;-- Free paged virtual memory region from OS (UNIX)
	;-------------------------------------------	
	OS-free-virtual: func [
		ptr [int-ptr!]							;-- address of memory region to release
	][
		if negative? OS-munmap as byte-ptr! ptr ptr/value [
			raise-error RED_ERR_VMEM_RELEASE_FAILED as-integer system/pc
		]
	]
]