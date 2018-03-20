## Loading stuff from a website directly

Rather than saving a file by hand (copy/paste or right-clicking and using "Download as..."), you can also get data straight in the ``Terminal`` and also in ``matlab``

### UNIX

In the terminal, try the following:

```bash
curl https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt
```

This will download the contents of the file at that location and put them in the ``terminal`` (technically, ``stdout``).

You can **redirect** this into a file using the > operator, thus:

```bash
curl https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt > mystery-timecourse.txt

# should run silently - unless there is an error
# and then it should be present!
ls my*

# the same works for other formats, too
curl https://farm8.staticflickr.com/7342/26661994064_4966d46cb3_c.jpg > mystery-image.jpg

# inspect
open mystery-image.jpg
```

During the download process you may see a message about progress. For very big files, this is very useful:

```
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                Dload  Upload   Total   Spent    Left  Speed
100 52739  100 52739    0     0   143k      0 --:--:-- --:--:-- --:--:--  143k
```


### Matlab

Matlab also has some tools to do this. You can look at the help for ``webread()`` and ``websave()``


```matlab
% make sure matlab uses the right tool to read NUMBERS
options = weboptions('ContentReader', @importdata)
% download into a variable:
m = webread('https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt', options);
% and plot in a figure
figure, plot(m, 'r-')
```

You can also try an image:

```matlab
anImage = webread('https://farm8.staticflickr.com/7342/26661994064_4966d46cb3_c.jpg', options);
% and show
figure, imshow(anImage), title('A lambertian brain')
```

- location of 1d data:
https://raw.githubusercontent.com/schluppeck/dafni/master/matlab_text/mystery-timecourse.txt

- an image from DS's flick account - showing a computer rendering of a freesurfer surface  :smile:
https://farm8.staticflickr.com/7342/26661994064_4966d46cb3_c.jpg

- W Shakespeare's *Richard III*: http://www.gutenberg.org/cache/epub/1103/pg1103.txt   - save this as a text file and use grep


## Back to main

[Go back to today's session aims](Readme.md)



## Notes

- [A blog post on rendering brains](http://www.psychology.nottingham.ac.uk/staff/ds1/rendering-brains/)
- Open source 3D creation and rendering - not really neuroscience, but fun nonetheless, http://blender.org
