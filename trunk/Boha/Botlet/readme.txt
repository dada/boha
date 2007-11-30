
Boha::Botlet HOW-TO
-------------------


EVENTS

alcune sub vengono richiamate automaticamente dal core
in funzione di eventi che accadono al bot

sub onPublic {
	my($bot, $who, $chan, $msg) = @_;
	...

sub onPrivate {
	my($bot, $who, $rcpt, $msg) = @_;
	...

sub onTimer {
	my $bot = shift;
	#viene richiamato ogni secondo circa
	...

sub onNotice {
	my($bot, $who, $rcpt, $msg) = @_;
	...

sub onJoin {
	my($bot, $who, $chan) = @_;
	...
	
sub onPart {
	my($bot, $who, $chan) = @_;
	...
	
sub onQuit {
	my($bot, $who, $msg) = @_;
	...
	
sub onKick {
	my($bot, $who, $kicker, $msg) = @_;
	...
	
sub onNick {
	my($bot, $who, $newnick) = @_;
	...


METHODS

sull'oggetto Boha (primo parametro passato agli events)
e' possibile eseguire:

$bot->say($dest, $text);
	dove $dest puo' essere un 'utente' oppure un '#canale'

$bot->is_registered($nick);
	interroga NickServ sull'autenticita' di $nick

$bot->todo($timeout, $action);
	imposta un'azione da eseguire in differita. $timeout
	e' il numero di secondi fra cui l'azione deve essere
	eseguita, $action è l'azione (una coderef)
	esempio:

		$bot->todo( 10, sub { $bot->say($chan, "sono passati 10 secondi") });
