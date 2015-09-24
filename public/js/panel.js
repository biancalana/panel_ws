$(document).ready(function() {

  var newLine = '<tr> \
                            <td><input type="text" id="ServerAddress-" class="form-control" aria-label="server address"></td> \
                            <td class="col-sm-1"><input id="ServerFailTimeout-" type="number" class="form-control"></td> \
                            <td class="col-sm-2"><input id="ServerWeight-" type="number" class="form-control"></td> \
                          </tr>';





  $("#tenant-add").on("click", function(event) {
    $('#tenant-add-modal').modal('show');
  });

  $("#server-pool-add").on("click", function(event) {
    $('#server-pool-add-modal').modal('show');
  });

  var newLine2 = '<tr> \
                            <td><input type="textarea" id="ServerAddress-" class="form-control" aria-label="server address"></td> \
                            <td class="col-sm-2"><input id="ServerFailTimeout-" type="textarea" class="form-control"></td> \
                            <td class="col-sm-2"><input id="ServerWeight-" type="textarea" class="form-control"></td> \
                            <td class="col-sm-1"> \
                              <button type="button" class="btn-sm btn-danger" id="ServerDelButton"> \
                                <span class="glyphicon glyphicon-remove" aria-hidden="true"></span> \
                              </button> \
                            </td> \
                          </tr>';


  //
  // Show serverpool modal configuration
  //
  $("a[id^=server-pool-show-]").on("click", function(event) {

    var server_pool_prefix  = 'server-pool-show-';
    var server_pool_str     = $(this).attr('id');

    var server_pool_id = server_pool_str.substring(server_pool_prefix.length);

    $.ajax({
      type: "GET",
      url: location.pathname + "/serverpool/get/" + server_pool_id,
      dataType:'json',
      success: function(res) {

        var ServerPoolType;

        $('#server-pool-show-modal').find('#myModalLabel').text(res.name);
        $('#server-pool-show-modal').find('#ServerPoolID').val(server_pool_id);

        //$('#server-pool-show-modal').find('input[id^=ServerPoolType]').find('option[value=' + res.']').val();
        //var serverPoolMethod  = $('#server-pool-show-modal').find('input[id^=ServerPoolMethod]:checked').val();

        serverPoolInfos = $.parseJSON(res.json);


        $('#server-pool-show-modal').find('tbody').empty();

        $.each(serverPoolInfos, function(ServerPoolType, ServerCfg) {

          $('#server-pool-show-modal :input[value=' + ServerPoolType + ']').prop('checked', true);
          $('#server-pool-show-modal :input[value=' + ServerPoolType + ']').prev().button('toggle');

          console.log($('#server-pool-show-modal :input[value=' + ServerPoolType + ']').prev());
          console.log($('#server-pool-show-modal :input[value=' + ServerPoolType + ']').prev().attr('class'));
          console.log($('#server-pool-show-modal :input[value=' + ServerPoolType + ']').prop('checked'));
          //console.log(ServerCfg.upstream.servers);

          for ( var i in ServerCfg.upstream.servers ) {

            var server = ServerCfg.upstream.servers[i];
            var server_counter = 1 + parseInt(i);

            _newLine = $(newLine2).clone();

            $('#server-pool-show-modal').find('tbody').append(_newLine);

            $('#server-pool-show-modal').find("#ServerAddress-").val(server.addr);
            $('#server-pool-show-modal').find("#ServerAddress-").attr('id', 'ServerAddress-' + server_counter);

            $('#server-pool-show-modal').find("#ServerFailTimeout-").val(server.fail_timeout);
            $('#server-pool-show-modal').find("#ServerFailTimeout-").attr('id', 'ServerFailTimeout-' + server_counter);

            $('#server-pool-show-modal').find("#ServerWeight-").val(server.weight);
            $('#server-pool-show-modal').find("#ServerWeight-").attr('id', 'ServerWeight-' + server_counter);

            $('#server-pool-show-modal').find("#ServerCounter").val(server_counter);
          }

        });

        // Make tables editable
        $('#server-pool-show-modal').find('#ServersTable').editableTableWidget();
        //$('#mainTable').find('#ServersTable').editableTableWidget().numericInputExample().find('td:first').focus();
        //$('#mainTable').editableTableWidget().numericInputExample().find('td:first').focus();



        $('#server-pool-show-modal').modal('show');
        //alert(res.name);
        //var serverpoolInfo = $.parseJSON(res);
        //alert(serverpoolInfo.name);
      }
    });
  });


  //
  // Add New ServerPool
  //
  $("#ServerPoolAdd").on("click", function(event) {

    var serverPoolName = $('#ServerPoolName').val();
    var serverPoolType = $('#ServerPoolType').val();
    var serverPoolMethod = $('#ServerPoolMethod').val();

    var ServerPoolInfo = {};

    ServerPoolInfo[serverPoolType] = {
      "upstream": {
        "name": serverPoolName,
        "servers": []
      }
    }

    //alert(serverPoolName);
    //alert(serverPoolType);
    //alert(serverPoolMethod);
    //alert( $("#ServerCounter").val());

    for ( var i = 1 ; i <= $("#ServerCounter").val(); i++ ) {
      //alert($("#ServerAddress-" + i).val());
      var server = {
        "addr":   $("#ServerAddress-" + i).val(),
        "fail_timeout": $("#ServerFailTimeout-" + i).val(),
        "weight": $("#ServerWeight-" + i).val()
      };
      ServerPoolInfo[serverPoolType]['upstream']['servers'].push(server);
    }


    $.ajax({
      type: "POST",
      url: location.pathname + "/serverpool/add",
      dataType: "json",
      success: function(msg) {
        $('#server-pool-add-modal').modal('hide');
        alert("ServerPool added successful !");
        window.location.href = location.pathname;
      },
      data: JSON.stringify(ServerPoolInfo)
    });
  });

  //
  // Change Existant ServerPool
  //
  $("#ServerPoolChange").on("click", function(event) {

    var serverPoolID      = $('#server-pool-show-modal').find('#ServerPoolID').val();
    var serverPoolName    = $('#server-pool-show-modal').find('#ServerPoolName').val();
    var serverPoolType    = $('#server-pool-show-modal').find('input[id^=ServerPoolType]:checked').val();
    var serverPoolMethod  = $('#server-pool-show-modal').find('input[id^=ServerPoolMethod]:checked').val();

    var ServerPoolInfo = {};

    alert(serverPoolType);
    alert(serverPoolMethod);

    ServerPoolInfo[serverPoolType] = {
      "upstream": {
        "name": serverPoolName,
        "type": serverPoolType,
        "servers": []
      }
    }

    //alert(serverPoolName);
    //alert(serverPoolType);
    //alert(serverPoolMethod);
    //alert( $("#ServerCounter").val());

    for ( var i = 1 ; i <= $('#server-pool-show-modal').find("#ServerCounter").val(); i++ ) {

      var ServerAddress     = $('#server-pool-show-modal').find("#ServerAddress-" + i).val();
      var ServerFailTimeout = $('#server-pool-show-modal').find("#ServerFailTimeout-" + i).val();
      var ServerWeight      = $('#server-pool-show-modal').find("#ServerWeight-" + i).val();

      //alert($('#server-pool-show-modal').find("#ServerAddress-" + i).val());

      var server = {
        "addr":   ServerAddress,
        "fail_timeout": ServerFailTimeout,
        "weight": ServerWeight
      };
      ServerPoolInfo[serverPoolType]['upstream']['servers'].push(server);
    }


    $.ajax({
      type: "POST",
      url: location.pathname + "/serverpool/change/" + serverPoolID,
      dataType: "json",
      success: function(msg) {
        $('#server-pool-add-modal').modal('hide');
        alert("ServerPool changed successful !");
        window.location.href = location.pathname;
      },
      data: JSON.stringify(ServerPoolInfo)
    });
  });


  $("#TenantAdd").on("click", function(event) {
    var tenantName = $('#TenantName').val();

    $.ajax({
      type: "POST",
      url: "/tenant/add",
      success: function(msg) {
        $('#tenant-add-modal').modal('hide');
      },
      data: { name: tenantName }
    });

  });

  //
  // ServerPoolType & ServerPoolMethod radio checked
  //
  $('input:radio[id^=ServerPoolType]').on("change", function(event) {
    alert($(this).val());
    $(this).prop("checked", true);
    alert($(this).prop("checked"));
  });

  //
  // Add new server field to serverpool form modal
  //
  $('button[id^=server-add-button]').on("click", function(event) {

    var server_counter;

    var cur_modal;

    server_counter++;

    _newLine = $(newLine).clone();

    if ( $("#server-pool-show-modal").hasClass('in') ) {
      cur_modal = $("#server-pool-show-modal");
    }

    server_counter = 1 + parseInt($(cur_modal).find("#ServerCounter").val());

    $(cur_modal).find('tbody').append(_newLine);

    $(cur_modal).find("#ServerAddress-").attr('id', 'ServerAddress-' + server_counter);
    $(cur_modal).find("#ServerFailTimeout-").attr('id', 'ServerFailTimeout-' + server_counter);
    $(cur_modal).find("#ServerWeight-").attr('id', 'ServerWeight-' + server_counter);

    $(cur_modal).find("#ServerCounter").val(server_counter);

/*
    $('#ServersTable').find('tbody').append(_newLine);

    $('#ServersTable').find("#ServerAddress-").attr('id', 'ServerAddress-' + server_counter);
    $('#ServersTable').find("#ServerFailTimeout-").attr('id', 'ServerFailTimeout-' + server_counter);
    $('#ServersTable').find("#ServerWeight-").attr('id', 'ServerWeight-' + server_counter);

    $("#ServerCounter").val(server_counter);
*/
  });

  $("#vip-add").on("click", function(event) {
    $('#vip-add-modal').modal('show');
  });

  $('.btn-group[data-input]').each(function() {
  	var hidden = $('[name="' + $(this).data('input') + '"]');
  	$(this).on('click', '.btn', function() {
  		hidden.val($(this).val());
  	}).find('.btn').each(function() {
  		$(this).toggleClass('active', $(this).val() == hidden.val())
  	});
  });
});
