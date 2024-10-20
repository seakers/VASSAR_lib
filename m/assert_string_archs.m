function assert_string_archs(archs)
    for i = 1:length(archs)
        jess(['assert ' char(archs{i})]);
    end
end