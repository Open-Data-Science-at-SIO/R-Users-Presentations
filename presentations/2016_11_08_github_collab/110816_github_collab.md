Github Intro
================
Hao Ye
November 8, 2016

What is git? What is Github?
----------------------------

Git is a version control system, "a tool that keeps track of these changes for us and helps us version and merge our files." <http://swcarpentry.github.io/git-novice/01-basics/>

"GitHub is a code hosting platform for version control and collaboration. It lets you and others work together on projects from anywhere." <https://guides.github.com/activities/hello-world/>

"The **sweet spot for this kind of training is therefore the first years of graduate school**. At that point, students have *time to learn* (at least, more time than they’ll have once they’re faculty) and *real problems of their own* that they want to solve." [Wilson 2016](https://f1000research.com/articles/3-62/v2)

### Example Github repositories

-   Brian's repositories: <https://github.com/brianstock>
-   SIO-BUGS repository: <https://github.com/SIO-BUG/BUG-Resources>.
-   SIO-R-Users repository: <https://github.com/ha0ye/SIO-R-Users>.

### Unlimited private repos for students

While a student you can request a ["developer pack"](https://education.github.com/pack) that gives you unlimited private repositories for chapters/papers in progress.

Let's get started
-----------------

1.  Create Github account
2.  Clone/download SIO-R-Users repository

``` r
git status
git pull origin master
git status
```

1.  Create new folder and file
2.  Commit changes

``` r
git add -A
git commit -m “message”
git status
```

1.  Push to Github

``` r
git push origin master
```

1.  Check online, see changes

Future workflow: adding a presentation to R-Users Github
--------------------------------------------------------

``` r
...cd to SIO-R-Users folder...
git pull origin master
...make local changes...
git add -A
git commit -m “message”
git push origin master
```

Existing resources
------------------

In case this totally flops or we can't figure out your machine, [Software Carpentry](http://software-carpentry.org/lessons/) has a great set of tutorials for git/Github (as well as R and other things computing):

-   [Git intro (3 hour workshop)](http://swcarpentry.github.io/git-novice/reference/)
-   [Recorded git intro workshop](https://www.youtube.com/watch?v=hKFNPxxkbO0)

Github also has nice tutorials for getting started: <https://guides.github.com/>.
