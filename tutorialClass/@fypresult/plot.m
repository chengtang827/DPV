function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('GroupPlots',1,'GroupPlotIndex',1, ...
    'ReturnVars',{''}, 'ArgsOnly',0,'Original',0,'Dilate',0,'Protected',0,'Limit',0, ...
    'minColor',0,'maxColor',0,'PSTH',0,'OriginalModel',0,'RawOutput',0,'DilatedOutput',0,...
    'FullSquare',0,'HalfSquare',0,'ProctectedOutput',0);
Args.flags = {'ArgsOnly','Limit','Original','Dilate','Protected','PSTH','RawOutput','OriginalModel','FullSquare','HalfSquare',...
    'DilatedOutput','ProctectedOutput'};
[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
    % plot one data set at a time
    n = Args.NumericArguments{1};

    %     if(~Args.LabelsOff)
    %
    %     end

    if (Args.minColor == 0 && Args.maxColor == 0)
        clims = [-0.08 0.08];
    else
        clims = [Args.minColor Args.maxColor];
    end

    if(Args.Original)
        for k=1:7
            subplot(2,4,k),imagesc(obj.data.original((64*(n-1)+1):(n*64),:,k),clims)
            if (Args.Limit)
                hold on;
                y1=obj.data.limit(n,1)-1;
                y2=obj.data.limit(n,2)+1;
                x1=obj.data.limit(n,3)-1;
                x2=obj.data.limit(n,4)+1;
                line([x1 x1],[y1 y2],'color','r');
                line([x2 x2],[y1 y2],'color','r');
                line([x1 x2],[y1 y1],'color','r');
                line([x1 x2],[y2 y2],'color','r');
                hold off;
            end
            title(['Frame  ',num2str(k),])
        end
    end

    if(Args.Dilate)
        for k=1:7
            subplot(2,4,k),imagesc(obj.data.dilateRC((64*(n-1)+1):(n*64),:,k),clims)
            title(['Frame  ',num2str(k),])
        end
    end

    if(Args.Protected)
        for k=1:7
            subplot(2,4,k),imagesc(obj.data.protectedRC((64*(n-1)+1):(n*64),:,k),clims)
            title(['Frame  ',num2str(k),])
        end
    end



    if (Args.PSTH)
        frsize = find(isnan(obj.data.fr(n,:)));
        if (isempty(frsize))
            fr = obj.data.fr(n,:);
        else
            fr = obj.data.fr(n,1:frsize(1)-1);
        end
        subplot(4,1,1),plot(fr);
        title(['PSTH']);
    end

    %     if (Args.RawOutput)
    %
    %         frsize = find(isnan(obj.data.fr(n,:)));
    %         if (isempty(frsize))
    %             fr = obj.data.fr(n,:);
    %         else
    %             fr = obj.data.fr(n,1:frsize(1)-1);
    %         end
    %
    %         output1size = find(isnan(obj.data.output1(n,:)));
    %         if (isempty(output1size))
    %             output1 = obj.data.output1(n,:);
    %         else
    %             output1 = obj.data.output1(n,1:output1size(1)-1);
    %         end
    %         size1=size(output1);
    %         size2=size(fr);
    %         size_diff=size2-size1;
    %         output1(end:end+size_diff(2))=0;
    %
    %         corr1 = xcorr(fr,output1,1,'coef');
    %         plot(output1,'color','blue');
    %         legend(['correlation coeff =',num2str(corr1(2))]);
    %
    %     end
    %


    if (Args.RawOutput)

        clear fr;
        clear output1;
        clear output4;
        output4=[];

        frsize = find(isnan(obj.data.fr(n,:)));
        if (isempty(frsize))
            fr = obj.data.fr(n,:);
        else
            fr = obj.data.fr(n,1:frsize(1)-1);
        end

        outputsize = find(isnan(obj.data.output1(n,:)));
        if (isempty(outputsize))
            output1 = obj.data.output1(n,:);
        else
            output1 = obj.data.output1(n,1:outputsize(1)-1);
        end

        %
        size1=size(output1);
        size2=size(fr);
        size_diff=size2-size1;
        output1(end:end+size_diff(2))=0;

        if (Args.OriginalModel)
            ;

        elseif(Args.FullSquare == 1)

            output1 = output1.^2;

        elseif(Args.HalfSquare == 1)
            output4=-output1;
            output1((output1)<0) = 0;
            output1 = output1.^2;

            output4((output4)<0) = 0;
            output4 = output4.^2;

        end

        fr = fr';
        output1=output1';
        output4=output4';

        corr1 = xcorr(fr,output1,1,'coef');


        if (Args.FullSquare)
            plot(output1,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Full Square');

        elseif (Args.HalfSquare)
            x1=1:size(output1);
            corr4 = xcorr(fr,output4,1,'coef');
            plotyy(x1,output1,x1,output4);
            legend(['positive HS correlation coeff =',num2str(corr1(2)),' negative HS correlation coeff =',num2str(corr4(2))]);

            title('Half Square');

        else
            plot(output1,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Output');
        end
    end



    if (Args.DilatedOutput)

        clear fr;
        clear output2;
        clear output4;
        output4=[];

        frsize = find(isnan(obj.data.fr(n,:)));
        if (isempty(frsize))
            fr = obj.data.fr(n,:);
        else
            fr = obj.data.fr(n,1:frsize(1)-1);
        end

        outputsize = find(isnan(obj.data.output2(n,:)));
        if (isempty(outputsize))
            output2 = obj.data.output2(n,:);
        else
            output2 = obj.data.output2(n,1:outputsize(1)-1);
        end


        size1=size(output2);
        size2=size(fr);
        size_diff=size2-size1;
        output2(end:end+size_diff(2))=0;

        %
        if (Args.OriginalModel)
            ;

        elseif(Args.FullSquare == 1)

            output2 = output2.^2;

        elseif(Args.HalfSquare == 1)
            output4=-output2;
            output2((output2)<0) = 0;
            output2 = output2.^2;

            output4((output4)<0) = 0;
            output4 = output4.^2;

        end



        fr = fr';
        output2=output2';
        output4=output4';

        corr1 = xcorr(fr,output2,1,'coef');



        if (Args.FullSquare)
            plot(output2,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Full Square');
        elseif (Args.HalfSquare)
            x1=1:size(output2);
            plotyy(x1,output2,x1,output4);
            corr4 = xcorr(fr,output4,1,'coef');
            legend(['positive HS correlation coeff =',num2str(corr1(2)),' negative HS correlation coeff =',num2str(corr4(2))]);
            title('Half Square');

        else
            plot(output2,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Output');
        end
    end



    if (Args.ProctectedOutput)

        clear fr;
        clear output3;
        clear output4;
        output4=[];

        frsize = find(isnan(obj.data.fr(n,:)));
        if (isempty(frsize))
            fr = obj.data.fr(n,:);
        else
            fr = obj.data.fr(n,1:frsize(1)-1);
        end



        outputsize = find(isnan(obj.data.output3(n,:)));
        if (isempty(outputsize))
            output3 = obj.data.output3(n,:);
        else
            output3 = obj.data.output3(n,1:outputsize(1)-1);
        end

        size1=size(output3);
        size2=size(fr);
        size_diff=size2-size1;
        output3(end:end+size_diff(2))=0;
        %
        if (Args.OriginalModel)
            ;

        elseif(Args.FullSquare == 1)

            output3 = output3.^2;

        elseif(Args.HalfSquare == 1)
            output4=-output3;
            output3((output3)<0) = 0;
            output3 = output3.^2;

            output4((output4)<0) = 0;
            output4 = output4.^2;

        end


        fr = fr';
        output3=output3';
        output4=output4';

        corr1 = xcorr(fr,output3,1,'coef');


        if (Args.FullSquare)
            plot(output3,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Full Square');
        elseif (Args.HalfSquare)
            x1=1:size(output3);
            plotyy(x1,output3,x1,output4);
            corr4 = xcorr(fr,output4,1,'coef');

            legend(['positive HS correlation coeff =',num2str(corr1(2)),' negative HS correlation coeff =',num2str(corr4(2))]);
            title('Half Square');

        else
            plot(output3,'color','blue');
            legend(['correlation coeff =',num2str(corr1(2))]);
            title('Output');
        end



    end

else
    if (Args.RawOutput)

        y=[];
        y1=[];
        for n=1:16

            clear fr;
            clear output1;
            clear output4;
            output4=[];

            frsize = find(isnan(obj.data.fr(n,:)));
            if (isempty(frsize))
                fr = obj.data.fr(n,:);
            else
                fr = obj.data.fr(n,1:frsize(1)-1);
            end

            outputsize = find(isnan(obj.data.output1(n,:)));
            if (isempty(outputsize))
                output1 = obj.data.output1(n,:);
            else
                output1 = obj.data.output1(n,1:outputsize(1)-1);
            end

            %
            size1=size(output1);
            size2=size(fr);
            size_diff=size2-size1;
            output1(end:end+size_diff(2))=0;

            if (Args.OriginalModel)
                ;

            elseif(Args.FullSquare == 1)

                output1 = output1.^2;

            elseif(Args.HalfSquare == 1)
                output4=-output1;
                output1((output1)<0) = 0;
                output1 = output1.^2;

                output4((output4)<0) = 0;
                output4 = output4.^2;

            end

            fr = fr';
            output1=output1';
            output4=output4';

            corr1 = xcorr(fr,output1,1,'coef');
            if(~isempty(output4))
                corr4 = xcorr(fr,output4,1,'coef');
                y1= [y1;corr4(2)];
                y
                y1
            end


            y = [y;corr1(2)];
            y


        end

        if (Args.HalfSquare)
            plot(y,'-.r*','MarkerSize',10);
            hold on;
            plot(y1,'-.b*','MarkerSize',10);
            hold off;
            legend('positive HS correlation coeff ',' negative HS correlation coeff ');
            y
            y1
        else

            plot(y,'-.b*','MarkerSize',10);

        end
        %    end

    elseif (Args.DilatedOutput)

        y=[];
        y1=[];
        for n=1:16

            clear fr;
            clear output2;
            clear output4;
            output4=[];

            frsize = find(isnan(obj.data.fr(n,:)));
            if (isempty(frsize))
                fr = obj.data.fr(n,:);
            else
                fr = obj.data.fr(n,1:frsize(1)-1);
            end

            outputsize = find(isnan(obj.data.output1(n,:)));
            if (isempty(outputsize))
                output2 = obj.data.output2(n,:);
            else
                output2 = obj.data.output2(n,1:outputsize(1)-1);
            end

            %
            size1=size(output2);
            size2=size(fr);
            size_diff=size2-size1;
            output2(end:end+size_diff(2))=0;

            if (Args.OriginalModel)
                ;

            elseif(Args.FullSquare == 1)

                output2 = output2.^2;

            elseif(Args.HalfSquare == 1)
                output4=-output2;
                output2((output2)<0) = 0;
                output2 = output2.^2;

                output4((output4)<0) = 0;
                output4 = output4.^2;

            end

            fr = fr';
            output2=output2';
            output4=output4';

            corr1 = xcorr(fr,output2,1,'coef');
            if(~isempty(output4))
                corr4 = xcorr(fr,output4,1,'coef');
                y1= [y1;corr4(2)];
            end

            y = [y;corr1(2)];


        end
        if (Args.HalfSquare)
            plot(y,'-.r*','MarkerSize',10);
            hold on;
            plot(y1,'-.b*','MarkerSize',10);
            hold off;
            legend('positive HS correlation coeff ',' negative HS correlation coeff ');
            y
            y1
        else

           plot(y,'-.b*','MarkerSize',10);
            y

        end

        %end
    elseif (Args.ProctectedOutput)

        y=[];
        y1=[];
        for n=1:16

            clear fr;
            clear output3;
            clear output4;
            output4=[];

            frsize = find(isnan(obj.data.fr(n,:)));
            if (isempty(frsize))
                fr = obj.data.fr(n,:);
            else
                fr = obj.data.fr(n,1:frsize(1)-1);
            end

            outputsize = find(isnan(obj.data.output3(n,:)));
            if (isempty(outputsize))
                output3 = obj.data.output1(n,:);
            else
                output3 = obj.data.output1(n,1:outputsize(1)-1);
            end

            %
            size1=size(output3);
            size2=size(fr);
            size_diff=size2-size1;
            output3(end:end+size_diff(2))=0;

            if (Args.OriginalModel)
                ;

            elseif(Args.FullSquare == 1)

                output3 = output3.^2;

            elseif(Args.HalfSquare == 1)
                output4=-output3;
                output3((output3)<0) = 0;
                output3 = output3.^2;

                output4((output4)<0) = 0;
                output4 = output4.^2;

            end

            fr = fr';
            output1=output3';
            output4=output4';

            corr1 = xcorr(fr,output3,1,'coef');
            if(~isempty(output4))
                corr4 = xcorr(fr,output4,1,'coef');
                y1= [y1;corr4(2)];
            end

            y = [y;corr1(2)];

        end
        if (Args.HalfSquare)
            plot(y,'-.r*','MarkerSize',10);
            hold on;
            plot(y1,'-.b*','MarkerSize',10);
            hold off;
            legend('positive HS correlation coeff ',' negative HS correlation coeff ');
            y
            y1
        else

            plot(y,'-.b*','MarkerSize',10);
            y

        end

    end




end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% @dirfiles/PLOT takes 'LabelsOff' as an example
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % return the arguments that the user has specified
% rvarl = length(Args.ReturnVars);
% if(rvarl>0)
%     % assign requested variables to varargout
%     for rvi = 1:rvarl
%         varargout{1}{rvi*2-1} = Args.ReturnVars{rvi};
%         varargout{1}{rvi*2} = eval(Args.ReturnVars{rvi});
%     end
% end
RR = eval('Args.ReturnVars');
for i=1:length(RR) RR1{i}=eval(RR{i}); end 
varargout = getReturnVal(Args.ReturnVars, RR1);