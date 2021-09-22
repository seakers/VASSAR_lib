function [] = run_jess()
%RUN_JESS opens a GUI window with buttons to run and pause the rules engine
%   j is the jess.Rete object

    persistent control_window

%%
    if isempty(control_window)
        j = global_jess_engine();
        run_button  = javax.swing.JButton('Run');
        listener = j.eval([...
            '(implement java.awt.event.ActionListener using '...
                '(lambda (?method ?event) '...
                    ... you better execute the run function in a thread
                    ... other than the GUI's events thread :)
                    '(thread (lambda ($?) '...
                        '(beep) '...
                        '(printout t (run) " rules fired." crlf) '...
                        '(beep)))))'...
                ]);
        listener = listener.javaObjectValue(j.getGlobalContext());
        run_button.addActionListener(listener);

        halt_button = javax.swing.JButton('Pause');
        listener = j.eval([...
            '(implement java.awt.event.ActionListener using '...
                '(lambda (?method ?event) '...
                    '(halt) '...
                    '(beep)))'...
                ]);
        listener = listener.javaObjectValue(j.getGlobalContext());
        halt_button.addActionListener(listener);

        % clicking run more than once without halting the engine first
        % causes funny results, so be safe and don't do it
        
        control_window = javax.swing.JFrame();
        control_window.setSize(200, 100);
        content = control_window.getContentPane();
        content.setLayout(java.awt.FlowLayout());
        content.add(run_button);
        content.add(halt_button);
    end

%%    
    control_window.setVisible(true);
end