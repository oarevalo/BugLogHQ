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
		if(typeof doSearch == 'function') doSearch();
	});
	$('.searchCheckbox').click(function(){
		if(typeof doSearch == 'function') doSearch();
	});
	
	$('#newRuleSelector').change(function(){
		var rel = $(this).val();
		$('.ruleDescription').hide();
		$('#rule_'+rel).show();
	})
});

function confirmDeleteRule(index) {
	if(confirm("Are you sure you wish to remove the rule")) {
		document.location='index.cfm?event=extensions.doDeleteRule&index='+index;
	}
}
