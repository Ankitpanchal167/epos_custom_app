#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>
#include <signal.h>
#include <time.h>
#include <sys/types.h>

#define CLOCKID CLOCK_REALTIME
#define SIG SIGRTMIN

int fdev;
struct input_event ev;

timer_t timerid = 0;
struct sigevent sev;
struct itimerspec its;
struct sigaction sa;

unsigned int timer_val = 5;

static void handler(int sig, siginfo_t *si, void *uc)
{   
    system("poweroff");
    //signal(sig, SIG_IGN);
}

int setup_timer()
{
    /* Establish handler for timer signal */

    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = handler;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIG, &sa, NULL) == -1)
        return -1;

    /* Create the timer */

    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = SIG;
    sev.sigev_value.sival_ptr = &timerid;
    if (timer_create(CLOCKID, &sev, &timerid) == -1)
        return -1;

    /* Start the timer */

    its.it_value.tv_sec = timer_val;
    its.it_value.tv_nsec = 0;
    its.it_interval.tv_sec = its.it_value.tv_sec;
    its.it_interval.tv_nsec = its.it_value.tv_nsec;

    printf("Setting timer for %d seconds\n",timer_val);

    if (timer_settime(timerid, 0, &its, NULL) == -1)
        return -1;

    return 0;

}
 
int main()
{

	fdev = open("/dev/input/event0", O_RDWR);
	if (fdev == -1)
        {
                printf("Error in opening event file \n");
                exit(-1);
        }

	const size_t ev_size = sizeof(struct input_event);
	while(1)
	{
		read(fdev, &ev, ev_size);
		if(ev.type == EV_KEY && ev.code == KEY_POWER && ev.value == 1)
		{
			if(setup_timer() == -1)
				printf("Failed to setup timer\n");
		}

		if(ev.type == EV_KEY && ev.code == KEY_POWER && ev.value == 0)
		{
			if(timer_delete(timerid) == -1)
				printf("Failed to delete timer\n");
		}
	}

	close(fdev);
}
