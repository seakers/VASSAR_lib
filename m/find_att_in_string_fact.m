function val = find_att_in_string_fact(str,att)
   tmp = regexp(char(str),[ '(' att ' (([^)])+)'],'tokens');% (([^)])+)
   val = tmp{1};
end