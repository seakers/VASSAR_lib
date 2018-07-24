function stkDisconnectFromMatlab()

    global params;
    params.conid = -1;

    % Close the STK socket connection
    stkClose( 'all' );

end