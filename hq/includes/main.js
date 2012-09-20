/* main js routines */

$(document).ready(function(){
	$('#sendToEmailLink').click(function(){
		$('#dSendForm').slideToggle();
	});
	
	$('.cell_message').click(function(){
		var rel = $(this).attr("rel");
		document.location = rel;
	});
	
	$('.searchSelector').change(function(){
		var fldValue = $(this).val();
		var fldName = $(this).attr("name");
		var event = $("#currentEvent").val();
		updateFilter(event, fldName, escape(fldValue));
	});
	$('.searchCheckbox').click(function(){
		var fldName = $(this).attr("name");
		var fldChecked = $(this).is(":checked");
		var event = $("#currentEvent").val();
		updateFilter(event, fldName, fldChecked);
	});
	$('.searchSeverityCheckbox').click(function(){
		var chks = [];
		var fldName = $(this).attr("name");
		var event = $("#currentEvent").val();
		$('.searchSeverityCheckbox').each(function() {
			if($(this).is(":checked")) chks.push($(this).val())
		})
		updateFilter(event, fldName, chks.join(","));
	})
	$('#newRuleSelector').change(function(){
		var rel = $(this).val();
		$('.ruleDescription').hide();
		$('#rule_'+rel).show();
	})
	
	if (typeof __removeAlert === 'undefined') {
		// nothing here
	} else {
		setTimeout(removeAlert,3000);
	}	
});

function confirmDeleteRule(index) {
	if(confirm("Are you sure you wish to remove the rule")) {
		document.location='index.cfm?event=extensions.doDeleteRule&index='+index;
	}
}
function updateFilter(event, name, value) {
	document.location = "index.cfm?event="+event+"&"+name+"="+value;
}

function removeAlert() {
	$("#alert").fadeOut().empty();
}