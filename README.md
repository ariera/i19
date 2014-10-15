# I19 - focus on programming and forget about micromanaging your translation files

## The problem:
Adding and maintaning support for different languages in applications is not very much fun. When you are programming and you write a text that will have to be translated you have two options:

**Option one**, you would (in no particular order) do something like this:

* you write the code that calls the translation engine
* you think of a key for that translation
* you grep you project source to make sure that key doesn't already exist
* you also probably grep for the text to see if such a text has already been internationalised in the app
* you open the yaml file corresponding to you default locale and add the key along with its text
* lastly you open the rest of languages yaml files to add the same key with the different translations

This is a massive pain as a programmer. It completely breaks your workflow, your train of though. It is such a big task and a big mental context switch that many programmers prefer to take the second option:

* just write the plain text you wanted to write and continue programming
* once you are done with you feature (or every once in a while, depending how strict you are) you will scan your code in search for all of the untranslated strings in your app and proceed with the workflow above.

I used to go with option 2. And that is even worse. Translation work tends to accumulate, you miss some strings, and it feels like incredibly dull and boring task to do.

*Trivia: To facilitate finding of untranslated strings in the code (@fsainz)[https://github.com/fsainz] and I started writting __I19__ at the beggining of every string that should get translated, so we could then later easily grep them. Hence the name of this gem :)*

## The dream:
What if you could just code, and whenever you need to write a _internationalizable_ piece of text you just write it and you let some software take care of all the rest?

* Find out if a similar string already exists and suggest reusing it
* Find out if a translation key is already beign used and suggest reusing it
* Write for you the key and the text in the yaml file
* And optionally wirte for you the translations (or at list generate an empty yml file that a human translator can easily fill it in)

Well I don't know if all of that is possible, but I think the situation could improve. A lot.

## The solution:
So how exactly is I19 gonna help you ask? The idea is to support the following workflow:

1. Whenever you have to write some text you do it this way: `t('my_key', default:'my text')`
2. You keep coding
3. When you are done coding you go to the console and run: `i19 update_translations`
  1. the program will scan you `app` folder in search for calls to translations
  2. add to the default_locale yaml file the translation key `my_key` with its corresponding text
  3. create a separete file `translation_pending.yml` for every locale you have and add that key too
4. Then you should proceed to translate all the `translation_pending.yml` files (or send the to your translator)
5. run `i19 merge` to merge the `translation_pending.yml` files into its corresponding main locale yaml file

The program will also take care of situations like:

* if you update the "default" text it should update the default locale yaml file and mark the rest of locales pending
* it should help you find similar default texts in your code base. Currently this is done via the command `i19 find_key`. But I would like to improve this workflow (not sure how, though)
* it should help you find similar translation keys. Again, currently done via command line
* detect and higlight conflicts such the same key having different default translations in different parts of the code
* detect and higlight keys with no translation (either via the `default` parameter o because they are already present in the yml file)

## Current State
This gem is still in development. I wouldn't advice anybody to try it now unless you know what you are doing (which you probably won't unless I have already explained to you a couple of things, because there is no documentation whatsover :'( ).

However if you like the idea, wanna contribute, simply know more or get notified when I consider it to be ready to try, just send me a message via github.

## Thanks
I think this is all for the moment.

I just couldn't leave without thanking the (i18n-tasks)[https://github.com/glebm/i18n-tasks] project and their people. It has been a constant soure of inspirantion and motivation for this project. If you like what you read here you definetely wanna check their project too :)
