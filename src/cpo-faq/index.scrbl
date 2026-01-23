#lang scribble/manual

@(require "../../lib/bootscrbl.rkt")

@title{Your Information and @code{code.pyret.org}}

The online Pyret editor,
@link["https://code.pyret.org"]{@code{code.pyret.org}}, uses your Google
Account to store programs, and logs some information about your use of the
editor to help us debug issues and improve the editor. We never share or sell
the data we collect, and we don't collect very much information in the first
place. This page summarizes how the editor uses your account and data.

A more formal “legalese” version of our Privacy Policy is at
@link["https://code.pyret.org/privacy"]{@code{https://code.pyret.org/privacy}}.

@section[#:tag "logging"]{What information is stored on Pyret servers?}

The contents of files and programs are only stored in Google Drive, not on
code.pyret.org servers.  When you publish programs with the "Publish" button,
or open images from your Drive via the "Open" menu in the editor, the
@code{code.pyret.org} server stores the ID for that file so it can show it to
other users who view your program.

We store a refresh token for your Google Account, which is a standard
credential used for connecting services to Google services.

We log basic information about your use of @code{code.pyret.org} to help us
improve the language and editor, and enable some debugging: information about
errors and error messages, login status, and preferences like which mode is
used to display highlights with or if the type-checker is used.

If you opt to contribute detailed usage information under the menu on the
editor page, which is disabled by default, we will receive information about
the contents of your programs and the edits you make.

@section{What permissions does @code{code.pyret.org} ask for and why?}

@itemlist[

@item{@emph{Add itself to Google Drive}: This lets you right-click on Pyret
programs in Google Drive and "Open with Pyret."}

@item{@emph{View and manage Google Drive files and folders that you have opened
or created with this app}: This lets the editor see, save, publish, and re-open
programs you create.}

]

You can always go to
@link["https://security.google.com/settings/security/permissions"]{your
Google account settings} and remove all access that code.pyret.org has to your
account.  Your programs and @code{code.pyret.org} folders will not be deleted
if you do so.  You can always manually delete these folders and their contents
yourself.

Optionally (and not by default or on first login) you can give full access to
Drive, which enables some advanced workflows. This requires additional
permissions:

@itemlist[

@item{@emph{Manage your photos and videos} and @emph{View the photos, videos,
and albums in your Google Drive}:  This is used to import images into programs
from your Drive without using the "Import" menu (which can be useful if you
have a lot of images for a game, for example).}

@item{@emph{View and manage your spreadsheets on Google Drive}: This enables
importing tables and working with data sources that you upload to your Drive.}

]

@section{Where are things stored in my Drive?}

The site initially makes a single folder in your Google Drive, called
@code{code.pyret.org}, and stores all of your programs there, with the names
you choose for them.  They are all created with you as the owner, and private
to your account.  As you run programs, there is also a directory called
@code{code.pyret.org.compiled} that is used for caching compiled copies of
programs.

If you @emph{publish} programs, the site creates another folder, called
@code{code.pyret.org.shared}, and makes @emph{publicly-readable copies} of
programs you publish in that directory.  If you delete files in this folder,
links for those programs you have shared with others will stop working, but any
copies others have made will be theirs to keep.  Each time you publish a
program, a new copy is created from its current contents.

@section{How can I remove the access code.pyret.org has to my data?}

You can always go to
@link["https://security.google.com/settings/security/permissions?pli=1"]{https://security.google.com/settings/security/permissions?pli=1}
and remove all access that code.pyret.org has to your account.  Your programs
and the created folders will not be deleted if you do so.  You can
always manually delete the folder and its contents yourself.

@section{How can I see old versions of my programs?}

Google Drive automatically stores old versions of your programs as they are
saved (as it does for all files).  You can follow the instructions at
@link["https://support.google.com/drive/answer/2409045?hl=en"]{Google's support
site} to manage old versions of files that you may have saved over or renamed.

@section{Information for Network Administrators}

@code{code.pyret.org} uses several domains to serve the programming
environment. If you are configuring an allowlist or denylist in a school
networking tool, the service requires the following domains:

@verbatim{
*.pyret.org
*.googleapis.com
apis.google.com
*.gstatic.com
*.cloudfront.net
}

Each of these domains has a specific purpose:

@itemlist[
@item{@code{*.pyret.org} hosts this service.}
@item{@code{*.googlapis.com}, @code{*.gstatic.com}, and @code{apis.google.com} are all domains
  owned by Google that are used to save and load files from Google Drive and
  log in to Google accounts. (For example,
  @url{https://github.com/googleapis/googleapis},
  @url{https://developers.google.com/chart/interactive/docs/basic_load_libs})}
@item{@code{*.cloudfront.net} is a domain owned by Amazon Web Services that serves our
  large files efficiently across many geographic locations
  (@url{https://aws.amazon.com/cloudfront/})}
]

Please contact @code{admin@"@"pyret.org} or @code{joe.politz@"@"gmail.com} for help or more
information.

