''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2006 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


'' SCOPE..END SCOPE compound statement parsing
''
'' chng: sep/2004 written [v1ctor]

option explicit
option escape

#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\parser.bi"
#include once "inc\ast.bi"

'':::::
''ScopeStmtBegin  =   SCOPE .
''
function cScopeStmtBegin as integer
    dim as ASTNODE ptr n
    dim as FB_CMPSTMTSTK ptr stk

	function = FALSE

	'' SCOPE
	lexSkipToken( )

	n = astScopeBegin( )
	if( n = NULL ) then
		hReportError( FB_ERRMSG_RECLEVELTOODEPTH )
		exit function
	end if

	''
	stk = stackPush( @env.stmtstk )
	stk->id = FB_TK_SCOPE
	stk->scope.node = n

	function = TRUE

end function

'':::::
''ScopeStmtEnd  =     END SCOPE .
''
function cScopeStmtEnd as integer
	dim as integer iserror
	dim as FB_CMPSTMTSTK ptr stk

	function = FALSE

	stk = stackGetTOS( @env.stmtstk )
	iserror = (stk = NULL)
	if( iserror = FALSE ) then
		iserror = (stk->id <> FB_TK_SCOPE)
	end if

	if( iserror ) then
		hReportError( FB_ERRMSG_ENDSCOPEWITHOUTSCOPE )
		exit function
	end if

	'' END SCOPE
	lexSkipToken( )
	lexSkipToken( )

	''
	astScopeEnd( stk->scope.node )

	'' pop from stmt stack
	stackPop( @env.stmtstk )

	function = TRUE

end function
