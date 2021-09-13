function arc = Enum_partitions(varargin)

switch nargin
    case 1 % Bell numbers
        N_INSTR = varargin{1};
        arc(:,1) = [1;1];
        arc(:,2) = [1;2];

        for ins = 3:N_INSTR
            tmp3 = [];
            for a = 1:size(arc,2)
                    tmp = arc(:,a);
                    mx = max(tmp) + 1;
                    tmp2 = tmp;
                    for i = 1:mx-1
                        tmp2 = cat(2,tmp2,tmp);
                    end
                    tmp2(ins,:) = 1:mx;
                    tmp3 = [tmp3,tmp2];            
            end
            arc = tmp3;
        end
        
    case 2  % Stirling # of the 2nd kind (exactly k sats)
        N_INSTR = varargin{1};
        NSAT = varargin{2};
        arc(:,1) = [1;1];
        arc(:,2) = [1;2];

        for ins = 3:N_INSTR
            tmp3 = [];
            for a = 1:size(arc,2)
                    tmp = arc(:,a);
                    mx = max(tmp) + 1;
                    tmp2 = tmp;
                    for i = 1:mx-1
                        tmp2 = cat(2,tmp2,tmp);
                    end
                    tmp2(ins,:) = 1:mx;
                    tmp3 = [tmp3,tmp2];            
            end
            arc = tmp3;
        end
        arc2 = zeros(size(arc));
        nn = 1;
        for col = 1:size(arc,2)
            arch = arc(:,col);
            if max(arch) == NSAT
                arc2(:,nn) = arch;
                nn = nn + 1;
            end
        end
        arc2(:,nn:end) = [];
        arc = arc2;
    case 3 % Limit cardinality of subsets to MAX_INSTR_PER_SAT instruments per satellite, nsat is a range in this case
        N_INSTR = varargin{1};
        NSAT = varargin{2};
        MAX_INSTR_PER_SAT = varargin{3};
        arc(:,1) = [1;1];
        arc(:,2) = [1;2];

        for ins = 3:N_INSTR
            tmp3 = [];
            for a = 1:size(arc,2)
                    tmp = arc(:,a);
                    mx = max(tmp) + 1;
                    tmp2 = tmp;
                    for i = 1:mx-1
                        tmp2 = cat(2,tmp2,tmp);
                    end
                    tmp2(ins,:) = 1:mx;
                    tmp3 = [tmp3,tmp2];            
            end
            arc = tmp3;
        end
        arc2 = zeros(size(arc));
        nn = 1;
        for col = 1:size(arc,2)
            arch = arc(:,col);
             sats = PACK_arch2sats(arch');
             ninstrsat = cellfun(@length,sats);
            if (max(arch) >= min(NSAT) && max(arch) <= max(NSAT)) && (sum(ninstrsat>MAX_INSTR_PER_SAT)==0)
                arc2(:,nn) = arch;
                nn = nn + 1;
            end
        end
        arc2(:,nn:end) = [];
        arc = arc2;
    otherwise
end
return