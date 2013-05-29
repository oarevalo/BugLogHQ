/*
 * This is the loose JS that CF outputs for every instance of cfdump.
 * */

// for queries we have more than one td element to collapse/expand
var expand = "open";

dump = function( obj ) {
	var out = "" ;
	if ( typeof obj == "object" ) {
		for ( key in obj ) {
			if ( typeof obj[key] != "function" ) out += key + ': ' + obj[key] + '<br>' ;
		}
	}
}


cfdump_toggleRow = function(source) {
	//target is the right cell
	if(document.all) target = source.parentElement.cells[1];
	else {
		var element = null;
		var vLen = source.parentNode.childNodes.length;
		for(var i=vLen-1;i>0;i--){
			if(source.parentNode.childNodes[i].nodeType == 1){
				element = source.parentNode.childNodes[i];
				break;
			}
		}
		if(element == null)
			target = source.parentNode.lastChild;
		else
			target = element;
	}
	//target = source.parentNode.lastChild ;
	cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
}

cfdump_toggleXmlDoc = function(source) {

	var caption = source.innerHTML.split( ' [' ) ;

	// toggle source (header)
	if ( source.style.fontStyle == 'italic' ) {
		// closed -> short
		source.style.fontStyle = 'normal' ;
		source.innerHTML = caption[0] + ' [short version]' ;
		source.title = 'click to maximize' ;
		switchLongToState = 'closed' ;
		switchShortToState = 'open' ;
	} else if ( source.innerHTML.indexOf('[short version]') != -1 ) {
		// short -> full
		source.innerHTML = caption[0] + ' [long version]' ;
		source.title = 'click to collapse' ;
		switchLongToState = 'open' ;
		switchShortToState = 'closed' ;
	} else {
		// full -> closed
		source.style.fontStyle = 'italic' ;
		source.title = 'click to expand' ;
		source.innerHTML = caption[0] ;
		switchLongToState = 'closed' ;
		switchShortToState = 'closed' ;
	}

	// Toggle the target (everething below the header row).
	// First two rows are XMLComment and XMLRoot - they are part
	// of the long dump, the rest are direct children - part of the
	// short dump
	if(document.all) {
		var table = source.parentElement.parentElement ;
		for ( var i = 1; i < table.rows.length; i++ ) {
			target = table.rows[i] ;
			if ( i < 3 ) cfdump_toggleTarget( target, switchLongToState ) ;
			else cfdump_toggleTarget( target, switchShortToState ) ;
		}
	}
	else {
		var table = source.parentNode.parentNode ;
		var row = 1;
		for ( var i = 1; i < table.childNodes.length; i++ ) {
			target = table.childNodes[i] ;
			if( target.style ) {
				if ( row < 3 ) {
					cfdump_toggleTarget( target, switchLongToState ) ;
				} else {
					cfdump_toggleTarget( target, switchShortToState ) ;
				}
				row++;
			}
		}
	}
}

cfdump_toggleTable = function(source) {

	var switchToState = cfdump_toggleSource( source ) ;
	if(document.all) {
		var table = source.parentElement.parentElement ;
		for ( var i = 1; i < table.rows.length; i++ ) {
			target = table.rows[i] ;
			cfdump_toggleTarget( target, switchToState ) ;
		}
	}
	else {
		var table = source.parentNode.parentNode ;
		for ( var i = 1; i < table.childNodes.length; i++ ) {
			target = table.childNodes[i] ;
			if(target.style) {
				cfdump_toggleTarget( target, switchToState ) ;
			}
		}
	}
}

cfdump_toggleSource = function( source ) {
	if ( source.style.fontStyle == 'italic' || source.style.fontStyle == null) {
		source.style.fontStyle = 'normal' ;
		source.title = 'click to collapse' ;
		return 'open' ;
	} else {
		source.style.fontStyle = 'italic' ;
		source.title = 'click to expand' ;
		return 'closed' ;
	}
}

cfdump_toggleTarget = function( target, switchToState ) {
	if ( switchToState == 'open' )	target.style.display = '' ;
	else target.style.display = 'none' ;
}

// collapse all td elements for queries
cfdump_toggleRow_qry = function(source) {
	expand = (source.title == "click to collapse") ? "closed" : "open";
	if(document.all) {
		var nbrChildren = source.parentElement.cells.length;
		if(nbrChildren > 1){
			for(i=nbrChildren-1;i>0;i--){
				target = source.parentElement.cells[i];
				cfdump_toggleTarget( target,expand ) ;
				cfdump_toggleSource_qry(source);
			}
		}
		else {
			//target is the right cell
			target = source.parentElement.cells[1];
			cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
		}
	}
	else{
		var target = null;
		var vLen = source.parentNode.childNodes.length;
		for(var i=vLen-1;i>1;i--){
			if(source.parentNode.childNodes[i].nodeType == 1){
				target = source.parentNode.childNodes[i];
				cfdump_toggleTarget( target,expand );
				cfdump_toggleSource_qry(source);
			}
		}
		if(target == null){
			//target is the last cell
			target = source.parentNode.lastChild;
			cfdump_toggleTarget( target, cfdump_toggleSource( source ) ) ;
		}
	}
}

cfdump_toggleSource_qry = function(source) {
	if(expand == "closed"){
		source.title = "click to expand";
		source.style.fontStyle = "italic";
	}
	else{
		source.title = "click to collapse";
		source.style.fontStyle = "normal";
	}
}