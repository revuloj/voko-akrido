
:- use_module(library(http/http_open)).
:- use_module(library(sgml)).
:- use_module(library(xpath)).

elshuto_dir('http://reta-vortaro.de/tgz/').
elshuto_lst('dosieroj.xml').
zip_target_dir('../tmp/').

xml_archive(XmlUrl,File) :-
    elshuto_dir(U1),
    elshuto_lst(U2),
    atom_concat(U1,U2,Url),
    load_xml(Url,Dom,[]),
    xpath(Dom,//file(@name=File),_),
    sub_atom(File,0,_,_,'revoxml_'),
    atom_concat(U1,File,XmlUrl).

xml_download :-
    xml_archive(XmlUrl,File),
    zip_target_dir(ZipDir),
    atom_concat(ZipDir,File,XmlFile),
    (exists_file(XmlFile) -> format('jam ĉeestas: ~w~n',[XmlFile])
    ; download_file(XmlUrl,XmlFile)).

download_file(Url,File) :-
    setup_call_cleanup(
        (
            catch(
                    http_open(Url,InStream,[encoding(octet)]),
                    _E,
                    (format('~w not found.~n',[Url]), fail)),
            open(File,write,OutStream,[encoding(octet)])
        ),
        (
            debug(redaktilo(download),'downloading ~q to ~q',[Url,File]),
            format('downloading ~q to ~q',[Url,File]),
            copy_stream_data(InStream,OutStream)
        ),
        (
            close(InStream),
            close(OutStream)
        )
    ).

    